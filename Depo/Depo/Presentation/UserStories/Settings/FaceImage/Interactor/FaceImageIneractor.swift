//
//  FaceImageIneractor.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageInteractor {
    var output: FaceImageInteractorOutput!
    
    private let accountService = AccountService()

    private let analyticsManager: AnalyticsService = factory.resolve()
    
    private func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
        accountService.faceImageAllowed(success: { [weak self] response in
            self?.output.operationFinished()
            if let response = response as? FaceImageAllowedResponse, let allowed = response.allowed {
                completion(allowed)
            } else {
                completion(false)
            }
        }, fail: { [weak self] error in
            self?.fail(error: error.description)
            completion(false)
        })
    }
    
    private func fail(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.output.operationFinished()
            self?.output.showError(error: error)
        }
    }
}

// MARK: - FaceImageInteractorInput

extension FaceImageInteractor: FaceImageInteractorInput {
    func getFaceImageStatus() {
        faceImageAllowed { [weak self] result in
            DispatchQueue.main.async {
                self?.output.didFaceImageStatus(result)
            }
        }
    }
    
    func changeFaceImageStatus(_ isAllowed: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .faceRecognition, eventLabel: .faceRecognition(isAllowed))
        let accountService = AccountService()
        let parameters = FaceImageAllowedParameters(allowed: isAllowed)
        accountService.switchFaceImageAllowed(parameters: parameters, success: { [weak self] response in
            DispatchQueue.main.async {
                if isAllowed {
                    MenloworksEventsService.shared.onFaceImageRecognitionOn()
                } else {
                    MenloworksEventsService.shared.onFaceImageRecognitionOff()
                }
                self?.output.operationFinished()
            }

        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.failedChangeFaceImageStatus(error: error.description)
            }
        })
    }
    
    func trackScreen() {
        analyticsManager.logScreen(screen: .settingsFIR)
    }
    
}
