import SwiftUI
import SwiftData

struct MapListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameMap.name) private var maps: [GameMap]
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(maps) { map in
                    NavigationLink(destination: MapDetailView(map: map)) {
                        HStack {
                            Image(map.imageURL)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            
                            Text(map.name)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("CS2 Haritalar")
            .toolbar {
                Button("Çıkış") {
                    authVM.logout()
                }
            }
            .onAppear {
                if maps.isEmpty {
                    addDefaultMaps()
                }
            }
        }
    }
    
    private func addDefaultMaps() {
        let defaultMaps = [
            GameMap(name: "Dust 2", imageURL: "dust2"),
            GameMap(name: "Mirage", imageURL: "mirage"),
            GameMap(name: "Inferno", imageURL: "inferno"),
            GameMap(name: "Vertigo", imageURL: "vertigo"),
            GameMap(name: "Nuke", imageURL: "nuke"),
            GameMap(name: "Ancient", imageURL: "ancient")
        ]
        
        defaultMaps.forEach { map in
            modelContext.insert(map)
        }
        
        try? modelContext.save()
    }
} 
