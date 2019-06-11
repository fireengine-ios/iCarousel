import UIKit

extension UITextField {
    var placeholderLabel: UILabel? {
        return subviews
            .compactMap { $0 as? UILabel }
            .first { $0.text == placeholder || $0.attributedText == attributedPlaceholder}
    }
    
    func toggleTextFieldSecureType() {
        isSecureTextEntry.toggle()
        
        /// https://stackoverflow.com/a/35295940/5893286
        let font = self.font
        self.font = nil
        self.font = font
    }
    
    func addToolBarWithButton(title: String, target: Any, selector: Selector) {
        let doneButton = UIBarButtonItem(title: title,
                                         font: UIFont.TurkcellSaturaRegFont(size: 19),
                                         tintColor: UIColor.lrTealish,
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
