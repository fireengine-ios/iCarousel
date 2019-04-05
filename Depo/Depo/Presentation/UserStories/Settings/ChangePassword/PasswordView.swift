import UIKit

final class PasswordView: UIView, NibInit {
    
    @IBOutlet private weak var showPasswordButton: UIButton! {
        willSet {
            /// in IB: UIButton(type: .custom)
            newValue.isExclusiveTouch = true
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.setTitleColor(ColorConstants.lightText, for: .normal)
            newValue.setTitleColor(ColorConstants.lightText.lighter(by: 30), for: .highlighted)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var errorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textOrange
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 15)
            newValue.isHidden = true
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 21)
            newValue.textColor = UIColor.lrTealish
            newValue.borderStyle = .none
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightText
            newValue.isOpaque = true
        }
    }
    
    @IBAction private func onShowPasswordButton(_ sender: UIButton) {
        toggleTextFieldSecureType()
    }
    
    private func toggleTextFieldSecureType() {
        passwordTextField.isSecureTextEntry.toggle()
        
        let showPasswordButtonText = passwordTextField.isSecureTextEntry ? "Show" : "Hide"
        showPasswordButton.setTitle(showPasswordButtonText, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        toggleTextFieldSecureType()
    }
}

extension UITextField {
    func toggleTextFieldSecureType() {
        isSecureTextEntry.toggle()
        
        /// https://stackoverflow.com/a/35295940/5893286
        let font = self.font
        self.font = nil
        self.font = font
    }
}


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
    
    @IBAction private func onRefreshCaptchaButton(_ sender: UIButton) {
        getImageCaptcha()
    }
    
    @IBAction private func onSoundCaptchaButton(_ sender: UIButton) {
        getAudioCaptcha()
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
