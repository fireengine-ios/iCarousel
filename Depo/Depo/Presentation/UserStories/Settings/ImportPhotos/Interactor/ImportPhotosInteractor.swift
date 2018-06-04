//
//  ImportPhotosInteractor.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ImportFromFBInteractor: ImportFromFBInteractorInput {
    weak var output: ImportFromFBInteractorOutput?
    
    private let fbService = FBService()
    
    func requestPermissions() {
        fbService.requestPermissions(success: { [weak self] responseObject in
            let fbPermissions = responseObject as! FBPermissionsObject
            DispatchQueue.main.async {
                self?.output?.permissionsSuccessCallback(permissions: fbPermissions)
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.permissionsFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func requestToken(permissions: [String]) {
        fbService.requestToken(permissions: permissions, success: { [weak self] token in
            DispatchQueue.main.async {
                self?.output?.tokenSuccessCallback(token: token)
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.tokenFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func requestConnect(withToken token: String) {
        fbService.requestConnect(withToken: token, success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output?.connectSuccessCallback()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.connectFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func requestStatus() {
        fbService.requestStatus(success: { [weak self] responseObject in
            let fbStatus = responseObject as! FBStatusObject
            DispatchQueue.main.async {
                self?.output?.statusSuccessCallback(status: fbStatus)
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.statusFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func requestStart() {
        fbService.requestStart(success: { [weak self] _ in
            DispatchQueue.main.async {
                self?.output?.startSuccessCallback()
            }
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.startFailureCallback(errorMessage: error.description)
            }
        }
    }
    
    func requestStop() {
        fbService.requestStop(success: { [weak self] _ in
            DispatchQueue.main.async {
                MenloworksTagsService.shared.facebookImport(isOn: false)
                self?.output?.stopSuccessCallback()
            }
            
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output?.stopFailureCallback(errorMessage: error.description)
            }
        }
    }
}
