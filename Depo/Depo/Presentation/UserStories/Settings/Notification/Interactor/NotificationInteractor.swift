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
                    self?.output.fail(errorResponse: errorResponse)
                }
        })
        
    }
    
    func viewWillAppear() {
        //output.success()
    }

    func delete(with idList: [Int]) {
        service.delete(
            with: idList,
            success: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.output.success(on: #function)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.fail(errorResponse: errorResponse)
                }
        })
        
    }
    
    func read(with id: String) {
        service.read(with: id,
            success: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.output.success(on: #function)
                }
            }, fail: { [weak self] errorResponse in
                DispatchQueue.main.async {
                    self?.output.fail(errorResponse: errorResponse)
                }
        })
        
    }
}
