import SwiftUI
import SwiftData

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    func login(context: ModelContext) {
        Task {
            do {
                let descriptor = FetchDescriptor<User>()
                let allUsers = try context.fetch(descriptor)
                
                print("Fetched users count: \(allUsers.count)") // Debug için
                
                await MainActor.run {
                    if let matchingUser = allUsers.first(where: { user in
                        let usernameMatch = user.username.lowercased() == self.username.lowercased()
                        let passwordMatch = user.password == self.password
                        
                        print("Checking user: \(user.username)") // Debug için
                        print("Username match: \(usernameMatch)") // Debug için
                        print("Password match: \(passwordMatch)") // Debug için
                        
                        return usernameMatch && passwordMatch
                    }) {
                        print("Login successful for user: \(matchingUser.username)") // Debug için
                        self.currentUser = matchingUser
                        self.isAuthenticated = true
                        self.errorMessage = ""
                    } else {
                        print("No matching user found") // Debug için
                        self.errorMessage = "Kullanıcı adı veya şifre hatalı"
                        self.showError = true
                    }
                }
            } catch {
                print("Login error: \(error)") // Debug için
                await MainActor.run {
                    self.errorMessage = "Giriş yapılırken bir hata oluştu: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    func register(context: ModelContext) {
        Task {
            do {
                let descriptor = FetchDescriptor<User>()
                let existingUsers = try context.fetch(descriptor)
                
                await MainActor.run {
                    if existingUsers.contains(where: { $0.username == self.username }) {
                        self.errorMessage = "Bu kullanıcı adı zaten kullanılıyor"
                        self.showError = true
                        return
                    }
                    
                    let isAdmin = self.username.lowercased() == "talha" && self.password == "talha"
                    let newUser = User(username: self.username, password: self.password, isAdmin: isAdmin)
                    context.insert(newUser)
                    try? context.save()
                    
                    self.currentUser = newUser
                    self.isAuthenticated = true
                    self.errorMessage = ""
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Kayıt olurken bir hata oluştu"
                    self.showError = true
                }
            }
        }
    }
    
    func logout() {
        Task {
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.username = ""
                self.password = ""
                self.errorMessage = ""
            }
        }
    }
} 