import Foundation
import SwiftData

@Model
class User {
    var id: UUID
    var username: String
    var password: String
    var isAdmin: Bool
    
    init(username: String, password: String, isAdmin: Bool = false) {
        self.id = UUID()
        self.username = username
        self.password = password
        self.isAdmin = isAdmin
    }
} 