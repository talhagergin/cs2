import SwiftUI
import SwiftData

@MainActor
final class MapViewModel: ObservableObject {
    @Published var selectedMap: GameMap?
    @Published var selectedMarker: Marker?
    
    func loadMarkers(for map: GameMap, context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Marker>()
            let allMarkers = try context.fetch(descriptor)
            
            // İlgili haritaya ait markerları filtrele
            let filteredMarkers = allMarkers.filter { marker in
                marker.map?.id == map.id
            }
            
            // Haritanın markers array'ini güncelle
            map.markers = filteredMarkers
            
        } catch {
            print("Error loading markers: \(error)")
        }
    }
} 