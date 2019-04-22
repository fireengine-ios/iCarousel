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
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    var isTurkcellUser: Bool = false

    var statusTurkcellUser: Bool {
        return isTurkcellUser
    }

    
    func viewIsReady() {
        analyticsManager.logScreen(screen: .profileEdit)
        analyticsManager.trackDimentionsEveryClickGA(screen: .profileEdit)
        guard let userInfo_ = userInfo else {
            return
        }
        output.configurateUserInfo(userInfo: userInfo_)
    }
    
    private func isEmailChanged(email: String) -> Bool {
        return (email != userInfo?.email)
    }
    
    private func isPhoneChanged(phone: String) -> Bool {
        return (phone != userInfo?.phoneNumber)
    }
    
    func changeTo(name: String, surname: String, email: String, number: String) {
        if !Validator.isValid(email: email) {
            output.showError(error: TextConstants.errorInvalidEmail)
            return
        }
        if !Validator.isValid(phone: number) {
            output.showError(error: TextConstants.errorInvalidPhone)
            return
        }
        updateNameIfNeed(name: name, surname: surname, email: email, number: number)
    }
    
    func updateNameIfNeed(name: String, surname: String, email: String, number: String) {
        if name != userInfo?.name || surname != userInfo?.surname {
///changed due difficulties with complicated names(such as names that contain more than 2 words). Now we are using same behaviour as android client
            let parameters = UserNameParameters(userName: name, userSurName: surname)
            AccountService().updateUserProfile(parameters: parameters,
                                               success: { [weak self] responce in
                let nameIsEmpty = name.isEmpty
                MenloworksTagsService.shared.onProfileNameChanged(isEmpty: nameIsEmpty)
                MenloworksEventsService.shared.profileName(isEmpty: nameIsEmpty)
                self?.userInfo?.name = name
                self?.userInfo?.surname = surname
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
    
    func updateBirthday(_ birthday: String) {
        AccountService().updateUserBirthday(birthday) { error in
            self.output.showError(error: error.localizedDescription)
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
