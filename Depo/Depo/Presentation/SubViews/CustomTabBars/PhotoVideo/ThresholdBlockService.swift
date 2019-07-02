//
//  ThresholdBlockService.swift
//  Depo
//
//  Created by Konstantin on 10/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


class ThresholdBlockService {
    private var threshold: TimeInterval = 0
    private var queue = DispatchQueue(label: DispatchQueueLabels.thresholdService)
    private var canExecuteBlock: Bool = true
    
    
    init(threshold: TimeInterval, queue: DispatchQueue? = nil) {
        if let userQueue = queue {
            self.queue = userQueue
        }
        self.threshold = threshold
    }
    
    
    func execute(block: @escaping VoidHandler) {
        if canExecuteBlock {
            canExecuteBlock = false
            queue.asyncAfter(deadline: .now() + threshold) { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                block()
                self.canExecuteBlock = true
            }
        }
    }
}
