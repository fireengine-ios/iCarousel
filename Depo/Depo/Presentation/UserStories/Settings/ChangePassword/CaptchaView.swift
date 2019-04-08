import UIKit

final class CaptchaView: UIView {
    
    @IBOutlet private weak var captchaImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.layer.cornerRadius = 5
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = ColorConstants.darkBorder.cgColor
        }
    }
    
    @IBOutlet private weak var soundCaptchaButton: UIButton! {
        willSet {
            let image = newValue.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            newValue.setImage(image, for: .normal)
            
            newValue.isExclusiveTouch = true
            newValue.tintColor = ColorConstants.darkText
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var refreshCaptchaButton: UIButton! {
        willSet {
            let image = newValue.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
            newValue.setImage(image, for: .normal)
            
            newValue.isExclusiveTouch = true
            newValue.tintColor = ColorConstants.darkText
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var captchaAnswerTextField: InsetsTextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaItaFont(size: 20)
            newValue.textColor = UIColor.lrTealish
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.insetX = 16
            newValue.attributedPlaceholder = NSAttributedString(string: "Type the text",
                                                                attributes: [.foregroundColor: UIColor.lrTealish])
            
            newValue.layer.cornerRadius = 5
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = ColorConstants.darkBorder.cgColor
            
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
        }
    }
    
    @IBAction private func onRefreshCaptchaButton(_ sender: UIButton) {
        getImageCaptcha()
        captchaAnswerTextField.text = ""
    }
    
    @IBAction private func onSoundCaptchaButton(_ sender: UIButton) {
        getAudioCaptcha()
        captchaAnswerTextField.text = ""
    }
    
    var currentCaptchaUUID = ""
    
    private let captchaService = CaptchaService()
    private var player: AVAudioPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        getImageCaptcha()
    }
    
    private func generateCaptchaUUID() {
        currentCaptchaUUID = UUID().uuidString
        print("---", currentCaptchaUUID)
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
}
