import Foundation

protocol KeyboardHandler {}
extension KeyboardHandler where Self: UIViewController {
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
}

extension UIView: KeyboardHandler {
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(window?.endEditing))
        addGestureRecognizer(tapGesture)
    }
}
