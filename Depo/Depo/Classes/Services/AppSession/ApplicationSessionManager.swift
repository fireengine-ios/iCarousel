//
//  ApplicationSessionManager.swift
//  Depo_LifeTech
//
//  Created by Oleg on 22.09.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ApplicationSessionManager: NSObject {
    
    private static var uniqueInstance: ApplicationSessionManager?
    
    static let repeatCheckingSessionInterval: TimeInterval = 20 * 60 //20 minutes
    
    private override init() {
        super.init()
        let timer = Timer.scheduledTimer(timeInterval: ApplicationSessionManager.repeatCheckingSessionInterval,
                                         target: self,
                                         selector: #selector(checkSession),
                                         userInfo: nil,
                                         repeats: true)
        timer.fire()
    }
    
    @objc static func shared() -> ApplicationSessionManager {
        if uniqueInstance == nil {
            uniqueInstance = ApplicationSessionManager()
        }
        return uniqueInstance!
    }
    
    @objc static func start(){
        if uniqueInstance == nil {
            uniqueInstance = ApplicationSessionManager()
        }
    }
    
    @objc func checkSession(){
        guard ApplicationSession.sharedSession.session.authToken != nil,
            ReachabilityService().isReachable
        else {
            return
            
        }
        
        var isNeedUpdateToken = true
        if let authTokenExpirationTime = ApplicationSession.sharedSession.session.authTokenExpirationTime{
            let ttl = authTokenExpirationTime - Date().timeIntervalSince1970
            if (ttl > ApplicationSessionManager.repeatCheckingSessionInterval){
                isNeedUpdateToken = false
            }
        }
        
//        isNeedUpdateToken = true
        
        if (isNeedUpdateToken){
            updateSession()
        }
    }
    
    @objc func updateSession(){
        AuthenticationService().autificationByRememberMe(sucess: {
            print("session updated successfully")
        }, fail: { (error) in
            print("session updated with error")
            //logout
            let authService = AuthenticationService()
            authService.logout {
                DispatchQueue.main.async {
                    if ApplicationSession.sharedSession.session.rememberMeToken != nil {
                        let router = RouterVC()
                        router.setNavigationController(controller: router.onboardingScreen)
                    }
                }
            }
        })
    }
    
}
