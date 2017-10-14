//
//  UserProfileUserProfileInteractor.swift
//  Depo
//
//  Created by Oleg on 13/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UserProfileInteractor: UserProfileInteractorInput {

    weak var output: UserProfileInteractorOutput!
    
    weak var userInfo: AccountInfoResponse? = nil

    
    func viewIsReady(){
        guard let userInfo_ = userInfo else{
            return
        }
        output.configurateUserInfo(userInfo: userInfo_)
    }
    
    func fieldsValueChanged(name: String, email: String, number: String){
        if ((name.characters.count == 0) || (email.characters.count == 0) || (number.characters.count == 0)){
            output.setEditButtonEnable(enable: false)
            return
        }
        
        let flag = isNameChanged(name: name) || isEmailChanged(email: email) || isPhoneChanged(phone: number)
        output.setEditButtonEnable(enable: flag)
        
    }
    
    private func isNameChanged(name: String) -> Bool{
        let array = name.components(separatedBy: " ")
        let name_ = array[0]
        var surname_ = ""
        if (array.count > 1){
            surname_ = array [1]
        }
        
        return (name_ != userInfo?.name) || (surname_ != userInfo?.surname)
    }
    
    private func isEmailChanged(email: String) -> Bool{
        return (email != userInfo?.email)
    }
    
    private func isPhoneChanged(phone: String) -> Bool{
        return (phone != userInfo?.phoneNumber)
    }
    
    private func getSepareteName(nameString: String) -> (name: String, surName: String){
        let array = nameString.components(separatedBy: " ")
        let name_ = array[0]
        var surname_ = ""
        if (array.count > 1){
            surname_ = array [1]
        }
        return (name_, surname_)
    }
    
    func onEditButton(name: String, email: String, number: String){
        
        let group = DispatchGroup()
        var isRequestStarted = false
        if (isNameChanged(name: name)){
            
            group.enter()
            isRequestStarted = true
            
            let names = getSepareteName(nameString: name)
            
            let parameters = UserNameParameters(userName: names.name, userSurName: names.surName)
            AccountService().updateUserProfile(parameters: parameters, success: {(responce) in
                group.leave()
            }, fail: { (error) in
                group.leave()
            })
        }
        
        if (isEmailChanged(email: email)){
            group.enter()
            isRequestStarted = true
            let parameters = UserEmailParameters(userEmail: email)
            AccountService().updateUserEmail(parameters: parameters, success: { (responce) in
                group.leave()
            }, fail: { (error) in
                group.leave()
            })
            
        }
        
        if (isPhoneChanged(phone: number)){
            group.enter()
            isRequestStarted = true
            let parameters = UserPhoneNumberParameters(phoneNumber: number)
            AccountService().updateUserPhone(parameters: parameters, success: { (responce) in
                group.leave()
            }, fail: { (error) in
                group.leave()
            })
        }
        
        if (isRequestStarted){
            self.output.startNetworkOperation()
        }
        
        group.notify(queue: .main) { [weak self] in
            DispatchQueue.main.async {
                self?.output.stopNetworkOperation()
                self?.output.setEditButtonEnable(enable: false)
            }
        }
        
    }
    
}
