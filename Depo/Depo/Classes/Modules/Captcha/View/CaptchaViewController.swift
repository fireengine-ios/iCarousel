//
//  CaptchaCaptchaViewController.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CaptchaViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captchaPlaceholderLabel: UILabel!
    @IBOutlet weak var imageBackground: UIView!
    
    var currenrtCapthcaID: String = ""
    
    var captchaImage: UIImage? {
        didSet {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            image.backgroundColor = UIColor.clear
            image.image = captchaImage!
        }
    }

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        getCaptcha(withType: .image)
        captchaPlaceholderLabel.text = TextConstants.captchaPlaceholder
        imageBackground.layer.cornerRadius = 5
    }
    
    @IBAction func captchaRefresh(_ sender: Any) {
        getNewCapthca()
    }

    func refreshCapthcha() {
        getNewCapthca()
    }
    
    private func getNewCapthca() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        image.image = UIImage()
        image.backgroundColor = UIColor.darkGray
        getCaptcha(withType: .image)
    }
    
    @IBAction func playAudioCaptcha(_ sender: Any) {

    }
    
    class func initFromXib() -> CaptchaViewController {
        return CaptchaViewController(nibName: "CaptchaViewController", bundle: nil)
    }
    
    func getCaptcha(withType type: CaptchaType) {
        let captchaService = CaptchaService()
        
        
        captchaService.getCaptcha(type: type, sucess: { [weak self] (response) in
            
            DispatchQueue.main.async { [weak self] in
                if let captchaResponse =  response as? CaptchaResponse,
                    let _ = captchaResponse.type,
                    let captchaData =  captchaResponse.data {
                        self?.captchaImage = UIImage(data: captchaData)
                }
            }
            
        }) { (error) in
            DispatchQueue.main.async { 
                CustomPopUp.sharedInstance.showCustomAlert(withText: error.description, okButtonText: TextConstants.ok)
            }
        }
        
        currenrtCapthcaID = captchaService.uuid
    }
}
