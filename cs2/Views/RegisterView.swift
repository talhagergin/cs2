import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kayıt Ol")
                .font(.largeTitle)
                .bold()
            
            TextField("Kullanıcı Adı", text: $authVM.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Şifre", text: $authVM.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Kayıt Ol") {
                authVM.register(context: modelContext)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("İptal") {
                dismiss()
            }
        }
        .padding()
    }
} 