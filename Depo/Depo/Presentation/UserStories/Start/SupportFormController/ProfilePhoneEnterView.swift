import UIKit

/// down arrow setup as codeTextField.rightView
final class ProfilePhoneEnterView: UIView, FromNib {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.profilePhoneNumberTitle
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var codeTextField: UnderlineTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            newValue.returnKeyType = .done
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.enablesReturnKeyAutomatically = true
            if #available(iOS 11.0, *) {
                newValue.smartQuotesType = .no
                newValue.smartDashesType = .no
            }
            
            let image = UIImage(named: "ic_arrow_down")
            let imageView = UIImageView(image: image)
            newValue.rightView = imageView
            newValue.rightViewMode = .always
            
            /// true from IB by default
            newValue.adjustsFontSizeToFitWidth = false
            newValue.keyboardType = .numberPad
            
            newValue.underlineColor = ColorConstants.profileGrayColor
            
            newValue.addToolBarWithButton(title: TextConstants.nextTitle,
                                          target: self,
                                          selector: #selector(nextAfterCode))
        }
    }
    
    @IBOutlet private weak var numberTextField: UnderlineTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.placeholder = TextConstants.profilePhoneNumberPlaceholder
            
            newValue.returnKeyType = .done
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.enablesReturnKeyAutomatically = true
            if #available(iOS 11.0, *) {
                newValue.smartQuotesType = .no
                newValue.smartDashesType = .no
            }
            
            /// true from IB by default
            newValue.adjustsFontSizeToFitWidth = false
            
            newValue.underlineColor = ColorConstants.profileGrayColor
            
            newValue.addToolBarWithButton(title: TextConstants.nextTitle,
                                          target: self,
                                          selector: #selector(nextAfterNumber))
        }
    }
    
    /// use for background color or add subviews
    @IBOutlet private weak var contentView: UIView!
    
    var responderAfterNumber: UIResponder?
    
    /// awakeFromNib will not be called bcz of File Owner.
    /// it will be called only for "init?(coder".
    /// don't use it for setup with "init(frame"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupFromNib()
    }
    
    
    @objc private func nextAfterCode() {
        numberTextField.becomeFirstResponder()
    }
    
    @objc private func nextAfterNumber() {
        //_ = numberTextField.delegate?.textFieldShouldReturn?(numberTextField)
        responderAfterNumber?.becomeFirstResponder()
    }
}

//UITextField+Extensions
extension UITextField {
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
