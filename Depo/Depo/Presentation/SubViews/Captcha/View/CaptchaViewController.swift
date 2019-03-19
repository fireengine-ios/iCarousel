//
//  CaptchaCaptchaViewController.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class CaptchaViewController: ViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captchaPlaceholderLabel: UILabel!
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    
    private(set) var currentCaptchaID: String = ""
    private let captchaService = CaptchaService()
    private var player: AVAudioPlayer?
    
    var captchaImage: UIImage? {
        didSet {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            image.backgroundColor = UIColor.clear
            image.image = captchaImage
        }
    }
    
    var captchaAudio: Data? {
        didSet {
            if let data = captchaAudio {
                do {
                    player = try AVAudioPlayer(data: data)
                    player!.prepareToPlay()
                    player!.play()
                } catch {
                    
                }
            }
        }
    }
    
    class func initFromXib() -> CaptchaViewController {
        return CaptchaViewController(nibName: "CaptchaViewController", bundle: nil)
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        getImageCaptcha()
        captchaPlaceholderLabel.text = TextConstants.captchaPlaceholder
        imageBackground.layer.cornerRadius = 5
        inputTextField.delegate = self
        inputTextField.returnKeyType = .done
        inputTextField.autocorrectionType = .no
        inputTextField.tag = 33
    }
    
    // MARK: Actions
    
    @IBAction func captchaRefresh(_ sender: Any) {
        getNewCaptcha()
    }

    @IBAction func playAudioCaptcha(_ sender: Any) {
        getAudioCaptcha()
    }
    
    func refreshCapthcha() {
        getNewCaptcha()
    }
    
    public func getCaptchaID() -> String {
        return currentCaptchaID
    }
    
    public func getCaptchaAnswer() -> String {
        return inputTextField.text ?? ""
    }
    
    private func getNewCaptcha() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        image.image = UIImage()
        getImageCaptcha()
    }
    
    private func getImageCaptcha() {
        captchaService.getCaptcha(uuid: nil, type: .image, sucess: { [weak self] response in
            
            DispatchQueue.main.async { [weak self] in
                if let captchaResponse = response as? CaptchaResponse,
                    let _ = captchaResponse.type,
                    let captchaData = captchaResponse.data {
                        self?.captchaImage = UIImage(data: captchaData)
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
        
        currentCaptchaID = captchaService.uuid
    }
    
    private func getAudioCaptcha() {
        captchaService.getCaptcha(uuid: currentCaptchaID, type: .audio, sucess: { [weak self] response in
            
            DispatchQueue.main.async { [weak self] in
                if let captchaResponse = response as? CaptchaResponse,
                    let _ = captchaResponse.type,
                    let captchaData = captchaResponse.data {
                    self?.captchaAudio = captchaData
                }
            }
            
        }, fail: { error in
            DispatchQueue.main.async {
                UIApplication.showErrorAlert(message: error.description)
            }
        })
    }
}

extension CaptchaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
