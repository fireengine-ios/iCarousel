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
    
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute,
                                  relatedBy: self.relation,
                                  toItem: self.secondItem, attribute: self.secondAttribute,
                                  multiplier: multiplier, constant: self.constant)
    }
}
