import UIKit

/// down arrow setup as codeTextField.rightView
final class ProfilePhoneEnterView: UIView, FromNib {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
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
            newValue.autocapitalizationType = .none
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
            
            newValue.underlineColor = ColorConstants.profileGrayColor
        }
    }
    
    @IBOutlet private weak var numberTextField: UnderlineTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
//            newValue.insetX = 16
            newValue.placeholder = TextConstants.captchaAnswerPlaceholder
            
            newValue.returnKeyType = .done
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.autocapitalizationType = .none
            newValue.enablesReturnKeyAutomatically = true
            if #available(iOS 11.0, *) {
                newValue.smartQuotesType = .no
                newValue.smartDashesType = .no
            }
            
            /// true from IB by default
            newValue.adjustsFontSizeToFitWidth = false
            
            newValue.underlineColor = ColorConstants.profileGrayColor
        }
    }
    
    /// use for background color or add subviews
    @IBOutlet private weak var contentView: UIView!
    
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
    
    /// will not be called bcz of File Owner. don't use awakeFromNib
    override func awakeFromNib() {}
}
