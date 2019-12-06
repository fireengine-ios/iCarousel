import UIKit

// TODO: only numbers for iPad in numberTextField

/// down arrow setup as codeTextField.rightView
final class ProfilePhoneEnterView: UIView, FromNib {
    
    @IBOutlet public weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 2
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet public weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.profilePhoneNumberTitle
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet public weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.isHidden = true
        }
    }
    
    @IBOutlet public weak var codeTextField: UnderlineTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = textFieldColor
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
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
            
            newValue.underlineColor = ColorConstants.profileGrayColor
            
            /// true from IB by default
            newValue.adjustsFontSizeToFitWidth = false
            
            let telephonyService = CoreTelephonyService()
            
            /// empty for simulator
            newValue.text = telephonyService.callingCountryCode()

            #if targetEnvironment(simulator)
            newValue.text = "+375"
            #endif
            
            let phoneCodeInputView = PhoneCodeInputView()
            phoneCodeInputView.setValuePickerView(with: telephonyService.callingCountryCode())
            phoneCodeInputView.didSelect = { [weak newValue] gsmModel in
                newValue?.text = gsmModel.gsmCode
            }
            newValue.inputView = phoneCodeInputView
            
            /// to remove cursor bcz we have picker
            newValue.tintColor = .clear
            
            newValue.addToolBarWithButton(title: TextConstants.nextTitle,
                                          target: self,
                                          selector: #selector(nextAfterCode))
        }
    }
    
    @IBOutlet public weak var numberTextField: QuickDismissPlaceholderTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = textFieldColor
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.quickDismissPlaceholder = TextConstants.profilePhoneNumberPlaceholder
            
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
            newValue.keyboardType = .numberPad
            newValue.underlineColor = ColorConstants.profileGrayColor
            
            newValue.addToolBarWithButton(title: TextConstants.nextTitle,
                                          target: self,
                                          selector: #selector(nextAfterNumber))
        }
    }
    
    /// use for background color or add subviews
    @IBOutlet public weak var contentView: UIView!
    
    /// setup for Next button after numberTextField
    var responderOnNext: UIResponder?
    
    var isEditState: Bool {
        get {
            return codeTextField.isUserInteractionEnabled
        }
        set {
            codeTextField.isUserInteractionEnabled = newValue
            numberTextField.isUserInteractionEnabled = newValue
            codeTextField.textColor = newValue ? textFieldColor : ColorConstants.textDisabled
            numberTextField.textColor = newValue ? textFieldColor : ColorConstants.textDisabled
        }
    }
    
    private let textFieldColor = UIColor.black
    
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
        responderOnNext?.becomeFirstResponder()
    }
    
    func showSubtitleAnimated() {
        guard subtitleLabel.isHidden else {
            return
        }
        stackView.spacing = NumericConstants.profileStackViewShowSubtitleSpacing
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideSubtitleAnimated() {
        guard !subtitleLabel.isHidden else {
            return
        }
        stackView.spacing = NumericConstants.profileStackViewHiddenSubtitleSpacing
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.subtitleLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showTextAnimated(text: String) {
        subtitleLabel.text = text
        showSubtitleAnimated()
    }
}
