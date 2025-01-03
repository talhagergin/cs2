import SwiftUI
import SwiftData

struct MapDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = MapViewModel()
    @Bindable var map: GameMap
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedPosition: CGPoint?
    @State private var showingMarkerOptions = false
    @State private var showingVideoInput = false
    @State private var selectedMarkerType: MarkerType?
    @State private var videoURL: String = ""
    @State private var selectedMarker: Marker?
    @State private var showingVideo = false
    @State private var mapSize: CGSize = .zero
    @State private var selectedFilter: MarkerType?
    
    var filteredMarkers: [Marker] {
        guard let filter = selectedFilter else { return map.markers }
        return map.markers.filter { $0.type == filter }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Harita Bölümü
            GeometryReader { geometry in
                ZStack {
                    Image(map.imageURL)
                        .resizable()
                        .scaledToFit()
                        .background(
                            GeometryReader { imageGeometry in
                                Color.clear.onAppear {
                                    mapSize = imageGeometry.size
                                }
                            }
                        )
                        .overlay(
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { location in
                                    if authVM.currentUser?.isAdmin == true {
                                        let imageFrame = geometry.frame(in: .local)
                                        selectedPosition = CGPoint(
                                            x: location.x - imageFrame.minX,
                                            y: location.y - imageFrame.minY
                                        )
                                        showingMarkerOptions = true
                                    }
                                }
                        )
                    
                    // Markerları Göster
                    ForEach(filteredMarkers) { marker in
                        MarkerView(marker: marker, mapSize: mapSize)
                            .onTapGesture {
                                selectedMarker = marker
                                showingVideo = true
                            }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            
            // Utility Kategorileri
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Utility Kategorileri")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(MarkerType.allCases, id: \.self) { type in
                        Button(action: {
                            withAnimation {
                                selectedFilter = selectedFilter == type ? nil : type
                            }
                        }) {
                            HStack {
                                Image(type.imageName)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                
                                Text(type.rawValue)
                                
                                Spacer()
                                
                                Text("\(map.markers.filter { $0.type == type }.count)")
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            .background(selectedFilter == type ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical)
            }
        }
        .onChange(of: showingVideo) { _, isShowing in
            if !isShowing {
                selectedMarker = nil
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
            // Mevcut markerları yükle
            viewModel.loadMarkers(for: map, context: modelContext)
            
            // Marker'ları güncelle
            map.markers.forEach { marker in
                modelContext.insert(marker)
            }
            try? modelContext.save()
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
        
        // Marker'ı ilişkiye ekleyin
        map.markers.append(marker)
        
        // SwiftData bağlamında değişiklikleri kaydedin
        do {
            try modelContext.save()
        } catch {
            print("Hata: \(error.localizedDescription)")
        }
        
        // Reset states
        selectedPosition = nil
        selectedMarkerType = nil
        videoURL = ""
        showingVideoInput = false
    }

} 
