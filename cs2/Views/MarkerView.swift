import SwiftUI

struct MarkerView: View {
    let marker: Marker
    let mapSize: CGSize
    
    var body: some View {
        Image(marker.type.imageName)
            .resizable()
            .frame(width: 30, height: 30)
            .position(marker.position)
            .shadow(radius: 2)
            .animation(.spring(), value: marker.position)
    }
} 