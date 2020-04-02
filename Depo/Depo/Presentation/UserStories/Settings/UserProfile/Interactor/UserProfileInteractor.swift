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
    
    var secretQuestionsResponse: SecretQuestionsResponse?
    
    private var profileChanges: String?
    
    func viewIsReady() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoEditScreen())
        analyticsManager.logScreen(screen: .profileEdit)
        analyticsManager.trackDimentionsEveryClickGA(screen: .profileEdit)
        
        guard let userInfo = userInfo else {
            assertionFailure()
            return
        }
        
        configuresecretQuestionView(userInfo: userInfo)
        output.configurateUserInfo(userInfo: userInfo)
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

    func trackState(_ editState: GAEventLabel, errorType: GADementionValues.errorType?) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .myProfile,
                                            eventLabel: editState,
                                            errorType: errorType)
    }
    
    func trackProfileChanges() {
        guard let changes = profileChanges else {
            trackState(.save(isSuccess: true), errorType: nil)
            return
        }
        analyticsManager.trackProfileUpdateGAEvent(editFields: changes)
    }
    
    func trackSetSequrityQuestion() {
        analyticsManager.trackCustomGAEvent(eventCategory: .securityQuestion,
                                            eventActions: .securityQuestionClick,
                                            eventLabel: .empty)
    }
    
    private func isPhoneChanged(phone: String) -> Bool {
        return (phone != userInfo?.phoneNumber)
    }
    
    func changeTo(name: String, surname: String, email: String, number: String, birthday: String, address: String, changes: String) {
        profileChanges = changes
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
    
    private func updateNameIfNeed(name: String, surname: String, email: String, number: String, birthday: String, address: String) {
        if name != userInfo?.name || surname != userInfo?.surname {
///changed due difficulties with complicated names(such as names that contain more than 2 words). Now we are using same behaviour as android client
            let parameters = UserNameParameters(userName: name, userSurName: surname)
            AccountService().updateUserProfile(parameters: parameters,
                                               success: { [weak self] response in
                let nameIsEmpty = name.isEmpty
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
    
    private func updateEmailIfNeed(email: String, number: String, birthday: String, address: String) {
        if (isEmailChanged(email: email)) {
            let parameters = UserEmailParameters(userEmail: email)
            AccountService().updateUserEmail(parameters: parameters,
                                             success: { [weak self] response in
                self?.userInfo?.email = email
                self?.updatePhoneIfNeed(number: number, birthday: birthday, address: address)
            }, fail: { [weak self] error in
                self?.fail(error: error.description)
            })
        } else {
            updatePhoneIfNeed(number: number, birthday: birthday, address: address)
        }
    }
    
    private func updatePhoneIfNeed(number: String, birthday: String, address: String) {
        if (isPhoneChanged(phone: number)) {
            let parameters = UserPhoneNumberParameters(phoneNumber: number)
            AccountService().updateUserPhone(parameters: parameters,
                                             success: { [weak self] response in
                                                if let resp = response as? SignUpSuccessResponse {
                                                    self?.needSendOTP(response: resp)
                                                    self?.updateBirthdayIfNeeded(birthday, address: address)
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
    
    private func updateBirthdayIfNeeded(_ birthday: String, address: String) {
        /// Lines below are more correct but they're commented because of 400 error
        /// https://jira.turkcell.com.tr/browse/FE-1277
///        let oldBirthdayIsEmpty = (userInfo?.dob ?? "").isEmpty
        let newBirthdayIsEmpty = birthday.trimmingCharacters(in: .whitespaces).isEmpty
        
        /// if oldBirthdayIsEmpty && newBirthdayIsEmpty {
        if newBirthdayIsEmpty || userInfo?.dob == birthday {
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
        if (userInfo?.address == nil && address.isEmpty) || (userInfo?.address == address) {
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
    
    private func needSendOTP(response: SignUpSuccessResponse) {
        DispatchQueue.main.async { [weak self] in
            if let info = self?.userInfo {
                self?.output?.stopNetworkOperation()
                self?.output?.needSendOTP(response: response, userInfo: info)
            }
        }
    }
    
    private func allUpdated() {
        ///need to refresh local info after change
        SingletonStorage.shared.getAccountInfoForUser(forceReload: true, success: { [weak self] response in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.output.dataWasUpdated()
                self.output.stopNetworkOperation()
                
                self.trackProfileChanges()
            }
            
        }, fail: { [weak self] error in
            self?.fail(error: error.localizedDescription)
            
        })
    }
    
    private func fail(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.output.stopNetworkOperation()
            self?.output.showError(error: error)
        }
    }
    
    /// posible needs callback for slow internet
    private func configuresecretQuestionView(userInfo: AccountInfoResponse) {
        
        guard userInfo.hasSecurityQuestionInfo != nil else  {
            assertionFailure()
            return
        }

        guard let questionId = userInfo.securityQuestionId else {
            /// posible assertionFailure(). needs to check
            return
        }
        
        accountService.getListOfSecretQuestions { [weak self] response in
            switch response {
            case .success( let questions):
                guard let question = questions.first(where: { $0.id == questionId }) else {
                    assertionFailure("getListOfSecretQuestions must containts questionId. error on server")
                    return
                }
                
                self?.secretQuestionsResponse = question
                
            case .failed(_):
                /// This error doesn't handle
                break
            }
        }
        
    }
    
    func updateSecretQuestionsResponse(with secretQuestionWithAnswer: SecretQuestionWithAnswer) {
        guard
            let questionId = secretQuestionWithAnswer.questionId,
            let question = secretQuestionWithAnswer.question
        else {
            assertionFailure("problem with Answer: \(secretQuestionWithAnswer)")
            return
        }
        secretQuestionsResponse = SecretQuestionsResponse(id: questionId, text: question)
    }
}
