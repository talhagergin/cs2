import SwiftUI

struct VideoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var videoURL: String
    let onSave: () -> Void
    @State private var isValidURL = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("YouTube Video URL", text: $videoURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .onChange(of: videoURL) { _, newValue in
                        videoURL = URLHelper.cleanYouTubeURL(newValue)
                        isValidURL = URLHelper.getVideoID(from: videoURL) != nil
                    }
                
                Text("Örnek: https://www.youtube.com/watch?v=...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .navigationTitle("Video URL Ekle")
            .navigationBarItems(
                leading: Button("İptal") {
                    dismiss()
                },
                trailing: Button("Kaydet") {
                    onSave()
                    dismiss()
                }
                .disabled(!isValidURL)
            )
        }
    }
} 