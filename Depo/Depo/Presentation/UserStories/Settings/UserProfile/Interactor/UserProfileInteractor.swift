//
//  UserProfileUserProfileInteractor.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileInteractor: UserProfileInteractorInput {
    
    private lazy var accountService = AccountService()

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
    
    func updateUserInfo() {
        accountService.info(success: { response in
            guard let response = response as? AccountInfoResponse else {
                assertionFailure()
                return
            }
            DispatchQueue.toMain {
                SingletonStorage.shared.accountInfo = response
            }
        }) { error in
            // This error is't handling
        }
    }
    
    func updateSetQuestionView(with question: SecretQuestionWithAnswer) {
        output.updateSecretQuestionView(selectedQuestion: question)
    }

    func trackState(_ editState: GAEventLabel, errorType: GADementionValues.errorType?) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .myProfile,
                                            eventLabel: editState,
                                            errorType: errorType)
    }
    
    func trackSetSequrityQuestion() {
        analyticsManager.trackCustomGAEvent(eventCategory: .securityQuestion,
                                            eventActions: .securityQuestionClick,
                                            eventLabel: .empty)
    }
    
    private func isPhoneChanged(phone: String) -> Bool {
        return (phone != userInfo?.phoneNumber)
    }
    
    func changeTo(name: String, surname: String, email: String, number: String, birthday: String, address: String) {
        if !Validator.isValid(email: email) {
            output.showError(error: TextConstants.errorInvalidEmail)

            trackState(.save(isSuccess: false), errorType: .emailInvalidFormat)
            return
        }
        
        if !Validator.isValid(phone: number) {
            output.showError(error: TextConstants.errorInvalidPhone)

            trackState(.save(isSuccess: false), errorType: .phoneInvalidFormat)
            return
        }
        
        updateNameIfNeed(name: name, surname: surname, email: email, number: number, birthday: birthday, address: address)
    }
    
    func updateNameIfNeed(name: String, surname: String, email: String, number: String, birthday: String, address: String) {
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
                                                self?.updateEmailIfNeed(email: email, number: number, birthday: birthday, address: address)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updateEmailIfNeed(email: email, number: number, birthday: birthday, address: address)
        }
    }
    
    func updateEmailIfNeed(email: String, number: String, birthday: String, address: String) {
        if (isEmailChanged(email: email)) {
            let parameters = UserEmailParameters(userEmail: email)
            AccountService().updateUserEmail(parameters: parameters,
                                             success: { [weak self] response in
                                                MenloworksEventsService.shared.onEmailChanged()
                self?.userInfo?.email = email
                self?.updatePhoneIfNeed(number: number, birthday: birthday, address: address)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updatePhoneIfNeed(number: number, birthday: birthday, address: address)
        }
    }
    
    func updatePhoneIfNeed(number: String, birthday: String, address: String) {
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
            updateBirthdayIfNeeded(birthday, address: address)
        }
    }
    
    func updateBirthdayIfNeeded(_ birthday: String, address: String) {
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
            updateAddressIfNeeded(address)
        } else {
            accountService.updateUserBirthday(birthday) { [weak self] response in
                switch response {
                case .success(_):
                    self?.userInfo?.dob = birthday
                    self?.updateAddressIfNeeded(address)
                case .failed(let error):
                    self?.fail(error: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateAddressIfNeeded(_ address: String) {
        if userInfo?.address == address {
            allUpdated()
        } else {
            accountService.updateAddress(with: address) { [weak self] response in
                switch response {
                case .success(_):
                    self?.userInfo?.address = address
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
                
                self?.trackState(.save(isSuccess: true), errorType: nil)
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
