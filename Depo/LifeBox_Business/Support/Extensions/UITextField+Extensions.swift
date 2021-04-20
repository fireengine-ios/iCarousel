import UIKit

extension UITextField {
    /// call layoutIfNeeded() if placeholderLabel is nil
    var placeholderLabel: UILabel? {
        return subviews.first(where: { $0 is UILabel }) as? UILabel
    }
    
    func toggleTextFieldSecureType() {
        isSecureTextEntry.toggle()
        
        /// https://stackoverflow.com/a/35295940/5893286
        let font = self.font
        self.font = nil
        self.font = font
    }
    
    func addToolBarWithButton(title: String, target: Any, selector: Selector, font: UIFont = UIFont.TurkcellSaturaRegFont(size: 19), tintColor: UIColor = UIColor.lrTealish) {
        let doneButton = UIBarButtonItem(title: title,
                                         font: font,
                                         tintColor: tintColor,
                                         accessibilityLabel: title,
                                         style: .plain,
                                         target: target,
                                         selector: selector)
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        keyboardToolbar.sizeToFit()
        
        inputAccessoryView = keyboardToolbar
    }
}
