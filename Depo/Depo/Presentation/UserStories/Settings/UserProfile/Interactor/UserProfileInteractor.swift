//
//  UserProfileUserProfileInteractor.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileInteractor: UserProfileInteractorInput {

    weak var output: UserProfileInteractorOutput!
    
    var userInfo: AccountInfoResponse?
    
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
    
    func changeTo(name: String, surname: String, email: String, number: String, birthday: String) {
        if !Validator.isValid(email: email) {
            output.showError(error: TextConstants.errorInvalidEmail)
            return
        }
        if !Validator.isValid(phone: number) {
            output.showError(error: TextConstants.errorInvalidPhone)
            return
        }
        updateNameIfNeed(name: name, surname: surname, email: email, number: number, birthday: birthday)
    }
    
    func updateNameIfNeed(name: String, surname: String, email: String, number: String, birthday: String) {
        if name != userInfo?.name || surname != userInfo?.surname {
///changed due difficulties with complicated names(such as names that contain more than 2 words). Now we are using same behaviour as android client
            let parameters = UserNameParameters(userName: name, userSurName: surname)
            AccountService().updateUserProfile(parameters: parameters,
                                               success: { [weak self] response in
                let nameIsEmpty = name.isEmpty
                MenloworksTagsService.shared.onProfileNameChanged(isEmpty: nameIsEmpty)
                MenloworksEventsService.shared.profileName(isEmpty: nameIsEmpty)
                self?.userInfo?.name = name
                self?.userInfo?.surname = surname
                self?.updateEmailIfNeed(email: email, number: number, birthday: birthday)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updateEmailIfNeed(email: email, number: number, birthday: birthday)
        }
    }
    
    func updateEmailIfNeed(email: String, number: String, birthday: String) {
        if (isEmailChanged(email: email)) {
            let parameters = UserEmailParameters(userEmail: email)
            AccountService().updateUserEmail(parameters: parameters,
                                             success: { [weak self] response in
                                                MenloworksEventsService.shared.onEmailChanged()
                self?.userInfo?.email = email
                self?.updatePhoneIfNeed(number: number, birthday: birthday)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updatePhoneIfNeed(number: number, birthday: birthday)
        }
    }
    
    func updatePhoneIfNeed(number: String, birthday: String) {
        if (isPhoneChanged(phone: number)) {
            let parameters = UserPhoneNumberParameters(phoneNumber: number)
            AccountService().updateUserPhone(parameters: parameters,
                                             success: { [weak self] response in
                                                if let resp = response as? SignUpSuccessResponse {
                                                    self?.needSendOTP(response: resp)
                                                } else {
                                                    self?.fail(error: TextConstants.errorUnknown)
                                                }
                
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updateBirthdayIfNeeded(birthday)
        }
    }
    
    func updateBirthdayIfNeeded(_ birthday: String) {
        /// Lines below are more correct but they're commented because of 400 error
        /// https://jira.turkcell.com.tr/browse/FE-1277
///        let oldBirthdayIsEmpty = (userInfo?.dob ?? "").isEmpty
        let newBirthdayIsEmpty = birthday.trimmingCharacters(in: .whitespaces).isEmpty
        
///        if oldBirthdayIsEmpty && newBirthdayIsEmpty {
        if newBirthdayIsEmpty {
            allUpdated()
            return
        }
        
        if userInfo?.dob == birthday {
            allUpdated()
        } else {
            AccountService().updateUserBirthday(birthday) { [weak self] response in
                switch response {
                case .success(_):
                    self?.userInfo?.dob = birthday
                    self?.allUpdated()
                case .failed(let error):
                    self?.fail(error: error.localizedDescription)
                }
            }
        }
    }
    
    func needSendOTP(response: SignUpSuccessResponse) {
        DispatchQueue.main.async { [weak self] in
            if let info = self?.userInfo {
                self?.output?.stopNetworkOperation()
                self?.output?.needSendOTP(response: response, userInfo: info)
            }
        }
    }
    
    func allUpdated() {
        ///need to refresh local info after change
        SingletonStorage.shared.getAccountInfoForUser(forceReload: true, success: { [weak self] response in
            DispatchQueue.main.async { [weak self] in
                self?.output.dataWasUpdated()
                self?.output.stopNetworkOperation()
            }
        }, fail: { [weak self] error in
            self?.fail(error: error.localizedDescription)
        })
    }
    
    func fail(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.output.stopNetworkOperation()
            self?.output.showError(error: error)
        }
    }
    
}
