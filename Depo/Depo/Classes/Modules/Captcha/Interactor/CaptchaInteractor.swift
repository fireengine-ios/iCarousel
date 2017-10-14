//
//  CaptchaCaptchaInteractor.swift
//  Depo
//
//  Created by  on 03/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CaptchaInteractor: CaptchaInteractorInput {

    weak var output: CaptchaInteractorOutput!
    
    func getCaptcha(withType type: CaptchaType) {
        let t = CaptchaService()
        t.getCaptcha(type: type, sucess: { [weak self] (response) in
             DispatchQueue.main.async { [weak self] in
            if let captchaResponse =  response as? CaptchaResponse,
                let st = captchaResponse.type {
                
                let data = captchaResponse.data
                self?.output.recivedCaptcha(withType: st, data: data)
                
            }
            }
            
        }) { [weak self] (error) in
             DispatchQueue.main.async { [weak self] in
            self?.output.failedResponse(withText: error.description)
            }
        }
        
    }
    

}
