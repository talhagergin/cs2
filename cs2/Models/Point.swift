import Foundation

struct Point: Codable {
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init(cgPoint: CGPoint) {
        self.x = Double(cgPoint.x)
        self.y = Double(cgPoint.y)
    }
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
} 