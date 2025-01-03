import Foundation
import SwiftData

@Model
final class Marker {
    var id: UUID
    var type: MarkerType
    private var positionX: Double
    private var positionY: Double
    var videoURL: String
    @Relationship(inverse: \GameMap.markers) var map: GameMap?
    
    var position: CGPoint {
        get {
            CGPoint(x: positionX, y: positionY)
        }
        set {
            positionX = Double(newValue.x)
            positionY = Double(newValue.y)
        }
    }
    
    var cleanVideoURL: String {
        URLHelper.cleanYouTubeURL(videoURL)
    }
    
    init(type: MarkerType, position: CGPoint, videoURL: String, map: GameMap) {
        self.id = UUID()
        self.type = type
        self.positionX = Double(position.x)
        self.positionY = Double(position.y)
        self.videoURL = videoURL
        self.map = map
    }
}

enum MarkerType: String, Codable, CaseIterable {
    case smoke = "Smoke"
    case flash = "Flash"
    case molly = "Molly"
    
    var imageName: String {
        switch self {
        case .smoke: return "smoke_icon"
        case .flash: return "flash_icon"
        case .molly: return "molly_icon"
        }
    }
} 