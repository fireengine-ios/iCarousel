import UIKit

protocol CaptchaViewErrorDelegate: class {
    
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
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var refreshCaptchaButton: UIButton! {
        willSet {
            newValue.isExclusiveTouch = true
            newValue.tintColor = ColorConstants.darkText
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 15)
            newValue.numberOfLines = 0
            newValue.isHidden = true
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var captchaAnswerTextField: QuickDismissPlaceholderTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.quickDismissPlaceholder = TextConstants.captchaAnswerPlaceholder
            
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
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.profileGrayColor
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
        guard errorLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.isHidden = false
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func hideErrorAnimated() {
        guard !errorLabel.isHidden else {
            return
        }
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.errorLabel.isHidden = true
            /// https://stackoverflow.com/a/46412621/5893286
            self.layoutIfNeeded()
        }
    }
    
    func showErrorAnimated(text: String) {
        errorLabel.text = text
        showErrorAnimated()
    }
}
