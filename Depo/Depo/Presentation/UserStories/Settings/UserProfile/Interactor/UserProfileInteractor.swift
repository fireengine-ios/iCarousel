//
//  UserProfileUserProfileInteractor.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileInteractor: UserProfileInteractorInput {

    weak var output: UserProfileInteractorOutput!
    
    weak var userInfo: AccountInfoResponse?
    
    var isTurkcellUser: Bool = false

    var statusTurkcellUser: Bool {
        return isTurkcellUser
    }

    
    func viewIsReady() {
        guard let userInfo_ = userInfo else {
            return
        }
        output.configurateUserInfo(userInfo: userInfo_)
    }
    
    private func isNameChanged(name: String) -> Bool {
        let array = name.components(separatedBy: " ")
        let name_ = array[0]
        var surname_ = ""
        if (array.count > 1) {
            surname_ = array [1]
        }
        
        return (name_ != userInfo?.name) || (surname_ != userInfo?.surname)
    }
    
    private func isEmailChanged(email: String) -> Bool {
        return (email != userInfo?.email)
    }
    
    private func isPhoneChanged(phone: String) -> Bool {
        return (phone != userInfo?.phoneNumber)
    }
    
    private func getSepareteName(nameString: String) -> (name: String, surName: String) {
        let array = nameString.components(separatedBy: " ")
        let name_ = array[0]
        var surname_ = ""
        if (array.count > 1) {
            surname_ = array [1]
        }
        return (name_, surname_)
    }
    
    func changeTo(name: String, email: String, number: String) {
        if !Validator.isValid(email: email) {
            output.showError(error: TextConstants.errorInvalidEmail)
            return
        }
        if !Validator.isValid(phone: number) {
            output.showError(error: TextConstants.errorInvalidPhone)
            return
        }
        updateNameIfNeed(name: name, email: email, number: number)
    }
    
    func updateNameIfNeed(name: String, email: String, number: String) {
        if (isNameChanged(name: name)) {
            let names = getSepareteName(nameString: name)
            let parameters = UserNameParameters(userName: names.name, userSurName: names.surName)
            AccountService().updateUserProfile(parameters: parameters,
                                               success: {[weak self] responce in
                self?.userInfo?.name = name
                self?.updateEmailIfNeed(email: email, number: number)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updateEmailIfNeed(email: email, number: number)
        }
    }
    
    func updateEmailIfNeed(email: String, number: String) {
        if (isEmailChanged(email: email)) {
            let parameters = UserEmailParameters(userEmail: email)
            AccountService().updateUserEmail(parameters: parameters,
                                             success: { [weak self] responce in
                                                MenloworksEventsService.shared.onEmailChanged()
                self?.userInfo?.email = email
                self?.updatePhoneIfNeed(number: number)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updatePhoneIfNeed(number: number)
        }
    }
    
    func updatePhoneIfNeed(number: String) {
        if (isPhoneChanged(phone: number)) {
            let parameters = UserPhoneNumberParameters(phoneNumber: number)
            AccountService().updateUserPhone(parameters: parameters,
                                             success: { [weak self] responce in
                                                if let resp = responce as? SignUpSuccessResponse {
                                                    self?.needSendOTP(responce: resp)
                                                } else {
                                                    self?.fail(error: TextConstants.errorUnknown)
                                                }
                
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            allUpdated()
        }
    }
    
    func needSendOTP(responce: SignUpSuccessResponse) {
        DispatchQueue.main.async { [weak self] in
            if let info = self?.userInfo {
                self?.output?.stopNetworkOperation()
                self?.output?.needSendOTP(responce: responce, userInfo: info)
            }
        }
    }
    
    func allUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.output.dataWasUpdate()
            self?.output.stopNetworkOperation()
        }
    }
    
    func fail(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.output.stopNetworkOperation()
            self?.output.showError(error: error)
        }
    }
    
}
