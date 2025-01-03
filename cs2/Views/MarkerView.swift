import SwiftUI

struct MarkerView: View {
    let marker: Marker
    
    var body: some View {
        Image(marker.type.imageName)
            .resizable()
            .frame(width: 30, height: 30)
            .position(x: marker.position.x, y: marker.position.y)
            .shadow(radius: 2)
    }
}

extension MarkerType {
    var imageName: String {
        switch self {
        case .smoke: return "smoke_icon"
        case .flash: return "flash_icon"
        case .molly: return "molly_icon"
        }
    }
} 