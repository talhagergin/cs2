import SwiftUI

struct MarkerView: View {
    let marker: Marker
    let mapSize: CGSize
    
    var body: some View {
        Image(marker.type.imageName)
            .resizable()
            .frame(width: 30, height: 30)
            .position(
                x: marker.position.x * mapSize.width,
                y: marker.position.y * mapSize.height
            )
            .shadow(radius: 2)
    }
} 