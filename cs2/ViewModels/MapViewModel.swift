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
            let mapMarkers = allMarkers.filter { $0.map?.id == map.id }
            map.markers = mapMarkers
            try? context.save()
        } catch {
            print("Error loading markers: \(error)")
        }
    }
} 