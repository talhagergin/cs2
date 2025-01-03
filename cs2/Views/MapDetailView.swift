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
    
    var body: some View {
        VStack(spacing: 0) {
            // Harita Bölümü - Sabit Yükseklik
            GeometryReader { geometry in
                ZStack {
                    // Harita
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
                                        // Göreli pozisyonu hesapla
                                        let imageFrame = geometry.frame(in: .local)
                                        let relativeX = location.x - imageFrame.minX
                                        let relativeY = location.y - imageFrame.minY
                                        selectedPosition = CGPoint(x: relativeX, y: relativeY)
                                        showingMarkerOptions = true
                                    }
                                }
                        )
                    
                    // Markerları Göster
                    if !map.markers.isEmpty {
                        ForEach(map.markers) { marker in
                            MarkerView(marker: marker, mapSize: mapSize)
                                .onTapGesture {
                                    selectedMarker = marker
                                    showingVideo = true
                                }
                        }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            
            // Marker İstatistikleri
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Utility Sayıları")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(MarkerType.allCases, id: \.self) { type in
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
                    }
                }
                .padding(.vertical)
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
        
        // Pozisyonu normalize et
        let normalizedPosition = CGPoint(
            x: position.x / mapSize.width,
            y: position.y / mapSize.height
        )
        
        let marker = Marker(
            type: type,
            position: normalizedPosition,
            videoURL: videoURL,
            map: map
        )
        
        // Önce marker'ı ekle
        modelContext.insert(marker)
        
        // Sonra map.markers array'ini güncelle
        if map.markers == nil {
            map.markers = []
        }
        map.markers.append(marker)
        
        // Değişiklikleri kaydet
        try? modelContext.save()
        
        // Reset states
        selectedPosition = nil
        selectedMarkerType = nil
        videoURL = ""
        showingVideoInput = false
    }
} 