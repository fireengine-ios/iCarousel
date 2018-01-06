//
//  TermsAndServicesTermsAndServicesInteractor.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class TermsAndServicesInteractor: TermsAndServicesInteractorInput {

    weak var output: TermsAndServicesInteractorOutput!
    let eulaService = EulaService()
    
    let dataStorage = TermsAndServicesDataStorage()
    
    var isFromLogin = false
    
    var eula: Eula?
    
    func loadTermsAndUses() {
        
    eulaService.eulaGet(sucess: { [weak self] (eula) in
        guard let eulaR = eula as? Eula else {
            return
        }
        self?.eula = eulaR
        DispatchQueue.main.async { [weak self] in
            self?.output.showLoadedTermsAndUses(eula: eulaR.content!)
        }
        }, fail: { [weak self] (errorResponse) in
            DispatchQueue.main.async { [weak self] in
                self?.output.failLoadTermsAndUses(errorString: errorResponse.description)
            }
    })
    }
    
    func saveSignUpResponse(withResponse response: SignUpSuccessResponse, andUserInfo userInfo: RegistrationUserInfoModel) {
        dataStorage.signUpResponse = response
        dataStorage.signUpUserInfo = userInfo
    }
    
    var signUpSuccessResponse: SignUpSuccessResponse {
    
        return dataStorage.signUpResponse
    }
    
    var userInfo: RegistrationUserInfoModel {
    
        return dataStorage.signUpUserInfo
    }
    
    var cameFromLogin: Bool {
        return isFromLogin
    }
    
    func signUpUser() {
        let authenticationService = AuthenticationService()
        
        guard let signUpInfo = SingletonStorage.shared.signUpInfo,
            let eulaId = eula?.id
            else { return }

        let signUpUser = SignUpUser(phone: signUpInfo.phone, mail: signUpInfo.mail, password: signUpInfo.password, eulaId: eulaId)

        authenticationService.signUp(user: signUpUser, sucess: {  result in
            DispatchQueue.main.async { [weak self] in

                guard let t = result as? SignUpSuccessResponse else {
                        return
                }
                self?.dataStorage.signUpResponse = t
                self?.dataStorage.signUpUserInfo = SingletonStorage.shared.signUpInfo
                SingletonStorage.shared.referenceToken = t.referenceToken
                self?.output.signUpSuccessed()

            }
        }, fail: { [weak self] errorResponce in
            DispatchQueue.main.async {
                self?.output.signupFailed(errorResponce: errorResponce)
            }
        })
    }
    
    func applyEula(){
        guard let eula_ = eula, let eulaID = eula_.id else{
            return
        }
        
        eulaService.eulaApprove(eulaId: eulaID, sucess: { [weak self] (successResponce) in
            DispatchQueue.main.async {
                self?.output.eulaApplied()
            }
        }, fail: { [weak self] errorResponce in
            DispatchQueue.main.async {
                self?.output.applyEulaFaild(errorResponce: errorResponce)
            }
        })
    }
}
