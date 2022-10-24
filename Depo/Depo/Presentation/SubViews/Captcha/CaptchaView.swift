import UIKit

protocol CaptchaViewErrorDelegate: AnyObject {
    
    func showCaptchaError(error: Error)
}

final class CaptchaView: UIView, FromNib {
    
    @IBOutlet private weak var captchaImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.backgroundColor = ColorConstants.profileGrayColor
        }
    }
    
    @IBOutlet private weak var soundCaptchaButton: UIButton! {
        willSet {
            newValue.isExclusiveTouch = true
            newValue.tintColor = ColorConstants.darkText
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.accessibilityLabel = TextConstants.captchaSound
        }
    }
    
    @IBOutlet private weak var refreshCaptchaButton: UIButton! {
        willSet {
            newValue.isExclusiveTouch = true
            newValue.tintColor = ColorConstants.darkText
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.accessibilityLabel = TextConstants.captchaRefresh
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    @IBOutlet weak var errorContentView: UIView! {
        willSet {
            
            newValue.isOpaque = true
            newValue.isHidden = true
            newValue.backgroundColor = .clear
            newValue.layer.cornerRadius = 8
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.profileInfoOrange.cgColor
        }
    }
    
    @IBOutlet weak var captchaView: UIView! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkTextAndLightGray.cgColor
            newValue.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.profileInfoOrange.color
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var captchaAnswerTextField: QuickDismissPlaceholderTextField! {
        willSet {
            newValue.font = .appFont(.regular, size: 16.0)
            newValue.textColor = AppColor.label.color
            newValue.borderStyle = .none
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.quickDismissPlaceholder = TextConstants.captchaAnswerPlaceholder
            
            newValue.returnKeyType = .done
            
            /// removes suggestions bar above keyboard
            newValue.autocorrectionType = .no
            
            /// removed useless features
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.enablesReturnKeyAutomatically = true
            newValue.smartQuotesType = .no
            newValue.smartDashesType = .no
        }
    }
    
    @IBOutlet private weak var captchaBackView: UIView!{
        willSet {
            newValue.layer.cornerRadius = 8
            newValue.layer.maskedCorners = [.layerMinXMinYCorner]
        }
    }
    
    
    @IBOutlet weak var textFieldBackView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 8
            newValue.layer.borderColor = AppColor.darkTextAndLightGray.cgColor
            newValue.layer.borderWidth = 1.0
            newValue.layer.maskedCorners = [.layerMinXMaxYCorner,
                                            .layerMaxXMaxYCorner]
            
        }
    }
    
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.itemSeperator.color
            newValue.isOpaque = true
        }
    }
    
    @IBAction private func onRefreshCaptchaButton(_ sender: UIButton) {
        updateCaptcha()
    }
    
    @IBAction private func onSoundCaptchaButton(_ sender: UIButton) {
        getAudioCaptcha()
        clearCaptchaAnswer()
    }
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var currentCaptchaUUID = ""
    weak var delegate: CaptchaViewErrorDelegate?
    
    private let captchaService = CaptchaService()
    private var player: AVAudioPlayer?
    
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
        
        errorContentView.topAnchor.constraint(equalTo: captchaView.bottomAnchor,
                                             constant: -10).isActive = true
        stackView.sendSubviewToBack(errorContentView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        getImageCaptcha()
    }
    
    func updateCaptcha() {
        clearCaptchaAnswer()
        getImageCaptcha()
    }
    
    func clearCaptchaAnswer() {
        captchaAnswerTextField.text = ""
    }
    
    private func generateCaptchaUUID() {
        currentCaptchaUUID = UUID().uuidString
    }
    
    private func getImageCaptcha() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .captcha,
                                            eventLabel: .captcha(.changeClick))
        
        generateCaptchaUUID()
        
        captchaService.getCaptcha(uuid: currentCaptchaUUID, type: .image, sucess: { [weak self] response in
            if let captchaResponse = response as? CaptchaResponse,
                let _ = captchaResponse.type,
                let captchaData = captchaResponse.data,
                let captchaImage = UIImage(data: captchaData) {
                /// image size (240.0, 60.0)
                DispatchQueue.main.async { [weak self] in
                    self?.captchaImageView.image = captchaImage
                }
            }
            
            }, fail: { [weak self] error in
                self?.delegate?.showCaptchaError(error: error)
                
                /// When you open the LoginViewController, another request is made to the server, which will already show 503 error
                let topController = UIApplication.topController()
                if !((topController is LoginViewController) || (topController is RegistrationViewController)) {
                    if !error.isServerUnderMaintenance {
                        DispatchQueue.main.async {
                            UIApplication.showErrorAlert(message: error.description)
                        }
                    }
                }
        })
    }
    
    private func getAudioCaptcha() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .captcha,
                                            eventLabel: .captcha(.voiceClick))
        
        generateCaptchaUUID()
        
        captchaService.getCaptcha(uuid: currentCaptchaUUID, type: .audio, sucess: { [weak self] response in
            if let captchaResponse = response as? CaptchaResponse,
                let _ = captchaResponse.type,
                let captchaData = captchaResponse.data {
                DispatchQueue.main.async {
                    self?.playCaptchaAudio(from: captchaData)
                }
            }
            }, fail: { [weak self] error in
                self?.delegate?.showCaptchaError(error: error)
                
                 let topController = UIApplication.topController()
                if !((topController is LoginViewController) || (topController is RegistrationViewController)) {
                    DispatchQueue.main.async {
                        UIApplication.showErrorAlert(message: error.description)
                    }
                }
        })
    }
    
    private func playCaptchaAudio(from data: Data) {
        player?.stop()
        player = try? AVAudioPlayer(data: data)
        player?.prepareToPlay()
        player?.play()
    }
    
    func showErrorAnimated() {
        guard errorContentView.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorContentView.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideErrorAnimated() {
        guard !errorContentView.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorContentView.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showErrorAnimated(text: String) {
        errorLabel.text = text
        showErrorAnimated()
    }
}
