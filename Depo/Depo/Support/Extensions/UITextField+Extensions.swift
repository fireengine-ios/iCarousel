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

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
