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
    
    private func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
        let accountService = AccountService()
        accountService.faceImageAllowed(success: { response in
            DispatchQueue.main.async {
                if let response = response as? FaceImageAllowedResponse, let allowed = response.allowed {
                    completion(allowed)
                } else {
                    completion(false)
                }
            }
            
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.output.operationFailed()
                    completion(false)
                }
            }
        })
    }
}

// MARK: - FaceImageInteractorInput

extension FaceImageInteractor: FaceImageInteractorInput {
    
    func getFaceImageStatus() {
        faceImageAllowed { [weak self] result in
                self?.output.didFaceImageStatus(result)
        }
    }
    
}
