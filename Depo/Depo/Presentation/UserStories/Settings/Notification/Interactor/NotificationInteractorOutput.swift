//
//  NotificationInteractorOutput.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

protocol NotificationInteractorOutput: AnyObject {
    func success(with notifications: [NotificationServiceResponse])
    func fail()
}
