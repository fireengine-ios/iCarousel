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
