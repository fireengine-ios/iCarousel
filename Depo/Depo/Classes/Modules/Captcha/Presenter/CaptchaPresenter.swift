//
//  CaptchaCaptchaPresenter.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol CaptchaDelegate: class {
    
    func validateCaptcha()
}

class CaptchaPresenter: CaptchaModuleInput, CaptchaViewOutput, CaptchaInteractorOutput {

    weak var view: CaptchaViewInput!
    
    weak var captchaDelegate: CaptchaDelegate?
    
    var interactor: CaptchaInteractorInput!
    

    func viewIsReady() {
        // download captcha
        interactor.getCaptcha(withType: .image)
    }
    
    func refreshCapthca() {
        interactor.getCaptcha(withType: .image)
    }
    
    func playSoundCaptca() {
        // play captcha
//        interactor.getCaptcha(withType: .image)
    }
    
    func validateCaptcha() {
        captchaDelegate?.validateCaptcha()
    }
    
    func recivedCaptcha(withType type: CaptchaType, data: Data?) {
        guard let data = data else {
            return
        }
        view.captchaImage = UIImage(data: data)
    }
    
    func failedResponse(withText text: String) {
        
    }
}
