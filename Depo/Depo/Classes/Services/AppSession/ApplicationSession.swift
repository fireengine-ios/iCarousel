//
//  ApplicationSession.swift
//  Depo
//
//  Created by Aleksandr on 7/7/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import FBSDKLoginKit

class ApplicationSession: NSObject, NSCoding {
    
    static let sharedSession = ApplicationSession()
    
    var session : Sesssion
    var signUpInfo: RegistrationUserInfoModel?
    lazy var dropboxManager: DropboxManager = factory.resolve()
    
    override init() {
        session = Sesssion()
        super.init()
        restoreData()
    }
    
    func updateSession(loginData: LoginResponse) {
        session.rememberMeToken = loginData.rememberMeToken
        session.authToken = loginData.token
        saveData()
        
    
        FBSDKLoginManager().logOut()
        dropboxManager.logout()
    }
    
    // MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        session = aDecoder.decodeObject(forKey: "session") as! Sesssion
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(session, forKey: "session")
    }
    
    func saveData() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "ApplicationSession")
    }
    
   func restoreData() {

        guard let data = UserDefaults.standard.object(forKey: "ApplicationSession") as? Data,
              let tmp = NSKeyedUnarchiver.unarchiveObject(with: data) as? ApplicationSession  else {
                return
            }
            session = tmp.session
    }
}


class Sesssion: NSObject, NSCoding {
    
    
    let authTokenName = "authToken"
    let remeberMeTokenName = "remeberMeToken"
    let authTokenExpirationTimeName = "authTokenExpirationTime"
    let rememberMeFlagName = "rememberMeFlag"
    
    
    var authToken: String? {
        didSet {
            if authToken != nil{
                debugPrint("token is ", authToken!)
                authTokenExpirationTime = Date().timeIntervalSince1970 + NumericConstants.lifeSessionDuration
            }else{
                debugPrint("token is empty")
            }
        }
    }
    
    var rememberMeToken: String?
    
    var authTokenExpirationTime: TimeInterval?
    
    var rememberMe: Bool = false
    
    override init() {
        super.init()
    }
    
    
    //MARK: NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        authToken = aDecoder.decodeObject(forKey: authTokenName) as? String
        rememberMeToken = aDecoder.decodeObject(forKey: remeberMeTokenName) as? String
        authTokenExpirationTime = aDecoder.decodeDouble(forKey: authTokenExpirationTimeName)
        rememberMe = aDecoder.decodeBool(forKey: rememberMeFlagName)
    }
    
    func encode(with aCoder: NSCoder) {
        if let rmToken = rememberMeToken {
            aCoder.encode(rmToken, forKey: remeberMeTokenName)
        }
        
        if let rmToken = authToken {
            aCoder.encode(rmToken, forKey: authTokenName)
        }
        
        if let rmAuthTokenExpirationTime = authTokenExpirationTime{
            aCoder.encode(rmAuthTokenExpirationTime, forKey: authTokenExpirationTimeName)
        }
        
        aCoder.encode(rememberMe, forKey: rememberMeFlagName)

    }
    
}
