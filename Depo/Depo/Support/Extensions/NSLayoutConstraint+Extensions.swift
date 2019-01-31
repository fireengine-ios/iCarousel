import Foundation

extension NSLayoutConstraint {
    
    @discardableResult
    func setPriority(_ priority: Float) -> NSLayoutConstraint {
        self.priority = .init(priority)
        return self
    }
    
    func activate() {
        isActive = true
    }
}
