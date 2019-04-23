import UIKit

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
            newValue.isHidden = true
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var captchaAnswerTextField: InsetsTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
            newValue.textColor = UIColor.black
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.insetX = 0
            newValue.placeholder = TextConstants.captchaAnswerPlaceholder
            
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
    
    var currentCaptchaUUID = ""
    
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
            
        }, fail: { error in
            /// When you open the LoginViewController, another request is made to the server, which will already show 503 error
            if !error.isServerUnderMaintenance || !(UIApplication.topController() is LoginViewController) {
                DispatchQueue.main.async {
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        })
    }
    
    private func getAudioCaptcha() {
        generateCaptchaUUID()
        captchaService.getCaptcha(uuid: currentCaptchaUUID, type: .audio, sucess: { [weak self] response in
            if let captchaResponse = response as? CaptchaResponse,
                let _ = captchaResponse.type,
                let captchaData = captchaResponse.data {
                DispatchQueue.main.async {
                    self?.playCaptchaAudio(from: captchaData)
                }
            }
        }, fail: { error in
            DispatchQueue.main.async {
                UIApplication.showErrorAlert(message: error.description)
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
