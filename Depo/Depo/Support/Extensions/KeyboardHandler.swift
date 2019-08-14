import UIKit

protocol KeyboardHandler {}

extension KeyboardHandler where Self: UIViewController {
    func addTapGestureToHideKeyboard() {
        view.addTapGestureToHideKeyboard()
    }
}

extension KeyboardHandler where Self: UIView {
    func addTapGestureToHideKeyboard() {
        self.addTapGestureToHideKeyboard()
    }
}

private extension UIView {
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func closeKeyboard() {
        let view: UIView = window ?? self
        view.endEditing(true)
    }
}
