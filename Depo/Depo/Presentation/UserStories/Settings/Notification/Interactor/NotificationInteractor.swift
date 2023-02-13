//
//  NotificationInteractor.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class NotificationInteractor {
    weak var output: NotificationInteractorOutput!
    
    let service = NotificationService()
}

extension NotificationInteractor: NotificationInteractorInput {
    
    func viewIsReady() {
        service.fetch(
            success: { [weak self] response in
                guard let notification = response as? NotificationResponse else { return }
                DispatchQueue.main.async {
                    self?.output.success(with: notification.list)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.fail()
                }
        })
        
    }
    
    func viewWillAppear() {
        //output.success()
    }

}
