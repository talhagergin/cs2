import Foundation
import SwiftData

@Model
final class GameMap {
    var id: UUID
    var name: String
    var imageURL: String
    @Relationship(deleteRule: .cascade) var markers: [Marker]
    
    init(name: String, imageURL: String) {
        self.id = UUID()
        self.name = name
        self.imageURL = imageURL
        self.markers = []
    }
} 
