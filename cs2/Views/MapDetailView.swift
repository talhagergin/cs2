import SwiftUI
import SwiftData

struct MapDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MapViewModel()
    @Bindable var map: GameMap
    @EnvironmentObject var authVM: AuthViewModel
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGPoint.zero
    @State private var lastOffset = CGPoint.zero
    @State private var showingMarkerOptions = false
    @State private var selectedPosition: CGPoint?
    @State private var showingVideoInput = false
    @State private var selectedMarkerType: MarkerType?
    @State private var videoURL: String = ""
    @State private var selectedMarker: Marker?
    @State private var showingVideo = false
    @State private var frameSize: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    
    init(map: GameMap) {
        self.map = map
        _viewModel = StateObject(wrappedValue: MapViewModel())
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Image(map.imageURL)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(x: offset.x, y: offset.y)
                        .background(
                            GeometryReader { imageGeometry in
                                Color.clear.onAppear {
                                    imageSize = imageGeometry.size
                                }
                            }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    let newScale = scale * delta
                                    scale = min(max(newScale, 1.0), 4.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = CGPoint(
                                        x: lastOffset.x + value.translation.width,
                                        y: lastOffset.y + value.translation.height
                                    )
                                    let maxOffset = (scale - 1) * imageSize.width / 2
                                    offset.x = min(max(newOffset.x, -maxOffset), maxOffset)
                                    offset.y = min(max(newOffset.y, -maxOffset), maxOffset)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .simultaneousGesture(
                            TapGesture(count: 2).onEnded {
                                withAnimation {
                                    scale = scale > 1.0 ? 1.0 : 2.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        )
                        .onTapGesture { location in
                            if authVM.currentUser?.isAdmin == true {
                                selectedPosition = location
                                showingMarkerOptions = true
                            }
                        }
                    
                    // Markers overlay
                    ForEach(map.markers) { marker in
                        MarkerView(marker: marker)
                            .onTapGesture {
                                selectedMarker = marker
                                showingVideo = true
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Video Player alanı
            if let selectedMarker = selectedMarker {
                VideoPlayerView(url: selectedMarker.videoURL)
                    .frame(height: 200)
            }
        }
        .navigationTitle(map.name)
        .actionSheet(isPresented: $showingMarkerOptions) {
            ActionSheet(
                title: Text("Marker Ekle"),
                message: Text("Eklemek istediğiniz utility'i seçin"),
                buttons: [
                    .default(Text("Smoke")) {
                        selectMarkerType(.smoke)
                    },
                    .default(Text("Flash")) {
                        selectMarkerType(.flash)
                    },
                    .default(Text("Molly")) {
                        selectMarkerType(.molly)
                    },
                    .cancel(Text("İptal"))
                ]
            )
        }
        .sheet(isPresented: $showingVideoInput) {
            VideoInputView(videoURL: $videoURL) {
                if !videoURL.isEmpty {
                    addMarker()
                }
            }
        }
        .sheet(isPresented: $showingVideo) {
            if let marker = selectedMarker {
                NavigationView {
                    VideoPlayerView(url: marker.videoURL)
                        .navigationTitle(marker.type.rawValue)
                        .navigationBarItems(trailing: Button("Kapat") {
                            showingVideo = false
                        })
                }
            }
        }
        .onAppear {
            viewModel.loadMarkers(for: map, context: modelContext)
        }
    }
    
    private func selectMarkerType(_ type: MarkerType) {
        selectedMarkerType = type
        showingVideoInput = true
    }
    
    private func addMarker() {
        guard let position = selectedPosition,
              let type = selectedMarkerType,
              !videoURL.isEmpty else { return }
        
        let marker = Marker(
            type: type,
            position: position,
            videoURL: videoURL,
            map: map
        )
        
        modelContext.insert(marker)
        map.markers.append(marker)
        try? modelContext.save()
        
        // Reset states
        selectedPosition = nil
        selectedMarkerType = nil
        videoURL = ""
        showingVideoInput = false
    }
} 