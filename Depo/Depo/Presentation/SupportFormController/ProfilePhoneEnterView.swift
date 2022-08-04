import UIKit

// TODO: only numbers for iPad in numberTextField

/// down arrow setup as codeTextField.rightView
final class ProfilePhoneEnterView: UIView, FromNib {
    
    private let underlineLayer = CALayer()
    private let phoneBorderLayer = CALayer()
    private let underlineWidth: CGFloat = 1.0

    var underlineColor = AppColor.borderColor.color {
        didSet {
            underlineLayer.backgroundColor = underlineColor.cgColor
        }
    }
    
    @IBOutlet private weak var codeTextFieldBackView: UIView! {
        willSet {
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var phoneTextFieldBackView: UIView!  {
        willSet {
            newValue.backgroundColor = .clear
        }
    }
    
    
    
    @IBOutlet public weak var stackView: UIStackView! {
        willSet {
            newValue.spacing = 24
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet public weak var titleLabel: UILabel! {
        willSet {
            newValue.text = "  " + TextConstants.profilePhoneNumberTitle + "  "
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.light, size: 14.0)
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet public weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.borderColor.color
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.isHidden = true
        }
    }
    
    @IBOutlet public weak var codeTextField: UnderlineTextField! {
        willSet {
            newValue.textColor = AppColor.borderColor.color
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.borderStyle = .none
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.enablesReturnKeyAutomatically = true
            newValue.smartQuotesType = .no
            newValue.smartDashesType = .no
            
            newValue.rightViewMode = .always
            newValue.underlineColor = AppColor.primaryBackground.color
            
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
            phoneCodeInputView.didSelect = { [weak newValue, weak self] gsmModel in
                newValue?.text = gsmModel.gsmCode
                self?.onCodeChanged?()
            }
            newValue.inputView = phoneCodeInputView
            
            /// to remove cursor bcz we have picker
            newValue.tintColor = .clear
            
            newValue.addToolBarWithButton(title: TextConstants.nextTitle,
                                          target: self,
                                          selector: #selector(nextAfterCode))
        }
    }
    
    
    @IBOutlet public weak var arrowImageView: UIImageView!
    
    @IBOutlet public weak var numberTextField: QuickDismissPlaceholderTextField! {
        willSet {
            newValue.textColor = AppColor.borderColor.color
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.borderStyle = .none
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.quickDismissPlaceholder = TextConstants.profilePhoneNumberPlaceholder
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.enablesReturnKeyAutomatically = true
            newValue.smartQuotesType = .no
            newValue.smartDashesType = .no
            
            /// true from IB by default
            newValue.adjustsFontSizeToFitWidth = false
            newValue.keyboardType = .numberPad
            newValue.underlineColor = AppColor.primaryBackground.color
            
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
    
    var onCodeChanged: (() -> Void)?
    
    private let textFieldColor = AppColor.blackColor.color
    
    /// awakeFromNib will not be called bcz of File Owner.
    /// it will be called only for "init?(coder".
    /// don't use it for setup with "init(frame"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupUnderline()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupUnderline()
        
    }
    
    private func setup() {
        setupFromNib()
    }
    
    private func setupUnderline() {
        codeTextFieldBackView.layer.insertSublayer(underlineLayer, at: 1)
        phoneTextFieldBackView.layer.insertSublayer(phoneBorderLayer, at: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        underlineLayer.frame = CGRect(x: 0,
                                      y: 0,
                                      width: codeTextFieldBackView.frame.width,
                                      height: 56);
        
        phoneBorderLayer.frame = CGRect(x: 0,
                                        y: 0,
                                        width: phoneTextFieldBackView.frame.width,
                                        height: 56);
        
        underlineLayer.borderWidth = 1.0
        underlineLayer.borderColor = underlineColor.cgColor
        underlineLayer.backgroundColor = UIColor.clear.cgColor
        underlineLayer.cornerRadius = 8
        
        phoneBorderLayer.borderWidth = underlineLayer.borderWidth
        phoneBorderLayer.borderColor = underlineLayer.borderColor
        phoneBorderLayer.backgroundColor = underlineLayer.backgroundColor
        phoneBorderLayer.cornerRadius = underlineLayer.cornerRadius
        
        self.bringSubviewToFront(codeTextField)
        self.bringSubviewToFront(numberTextField)
        self.bringSubviewToFront(titleLabel)
        
        
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
        arrowImageView.image = Image.iconArrowDownActive.image
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
        arrowImageView.image = Image.iconArrowDown.image
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
    
    func showTextWithoutAnimation(text: String) {
        guard subtitleLabel.isHidden else {
            return
        }
        subtitleLabel.text = text
        subtitleLabel.isHidden = false
    }
}
