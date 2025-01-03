import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var authVM = AuthViewModel()
    @State private var showingRegister = false
    @State private var isLoggingIn = false
    
    var body: some View {
        if authVM.isAuthenticated {
            MapListView()
                .environmentObject(authVM)
        } else {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("CS2 LineUp")
                        .font(.largeTitle)
                        .bold()
                    
                    TextField("Kullanıcı Adı", text: $authVM.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Şifre", text: $authVM.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if isLoggingIn {
                        ProgressView()
                    } else {
                        Button("Giriş Yap") {
                            isLoggingIn = true
                            authVM.login(context: modelContext)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("Kayıt Ol") {
                        showingRegister = true
                    }
                }
                .padding()
                .alert("Hata", isPresented: $authVM.showError) {
                    Button("Tamam", role: .cancel) {
                        isLoggingIn = false
                    }
                } message: {
                    Text(authVM.errorMessage)
                }
                .sheet(isPresented: $showingRegister) {
                    RegisterView()
                        .environmentObject(authVM)
                }
                .onChange(of: authVM.isAuthenticated) { oldValue, newValue in
                    if newValue {
                        isLoggingIn = false
                    }
                }
            }
        }
    }
} 