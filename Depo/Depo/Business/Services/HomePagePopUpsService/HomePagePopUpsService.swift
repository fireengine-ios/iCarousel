//
//  HomePagePopUpsService.swift
//  Depo
//
//  Created by Raman Harhun on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class HomePagePopUpsService {
    
    static var shared = HomePagePopUpsService()
    
    private static let underlyingQueue = DispatchQueue(label: "HomePagePopUpsServiceQueueLabel")

    private static let popUpsOperationQueue: OperationQueue = {
        let newValue = OperationQueue()
        newValue.maxConcurrentOperationCount = 1
        newValue.qualityOfService = .default
        newValue.underlyingQueue = underlyingQueue
        
        return newValue
    }()
    
    ///
    /// use this method if you'd like to show pop up
    /// this pop will be shown ASAP without presentation issues
    /// hierarchy of presentable popUps please configure before adding
    ///
    func addPopUs(_ popUps: [BasePopUpController]) {
        let operations: [HomePagePopUpOperation] = popUps.map { popUp in
            let operation = HomePagePopUpOperation()
            operation.popUp = popUp
            
            return operation
        }
        
        print(operations.count)
        HomePagePopUpsService.popUpsOperationQueue.addOperations(operations, waitUntilFinished: true)
    }
    
    ///
    /// call on viewDidAppear
    /// this will continue presenting pop ups on the screen if in some reasons we left controller
    ///
    func continueAfterPushIfNeeded() {
        /// if fisrt operation is currently runing
        (HomePagePopUpsService.popUpsOperationQueue.operations.first as? HomePagePopUpOperation)?.continueAfterPush()
    }
}
