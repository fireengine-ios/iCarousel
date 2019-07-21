//
//  DispatchQueue+Main.swift
//  DispatchQueue+Main
//
//  Created by Bondar Yaroslav on 3/15/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import Foundation

// MARK: - MainQueue
/// http://blog.benjamin-encz.de/post/main-queue-vs-main-thread/
/// https://github.com/devMEremenko/EasyCalls/blob/master/Classes/Calls/Queues/Queues.swift
public extension DispatchQueue {
    
    private static let mainQueueKey = DispatchSpecificKey<String>()
    private static let mainQueueValue = "DispatchQueue.mainQueueValue"
    
    /// add to AppDelegate didFinishLaunchingWithOptions
    static func setupMainQueue() {
        DispatchQueue.main.setSpecific(key: mainQueueKey, value: mainQueueValue)
    }
    
    static var isMainQueue: Bool {
        return DispatchQueue.getSpecific(key: mainQueueKey) != nil
    }
    
    /**
     Being on the main thread does not guarantee to be in the main queue.
     It means, if the current queue is not main, the execution will be moved to the main queue.
     */
    public static func toMain(_ handler: @escaping VoidHandler) {
        if DispatchQueue.isMainQueue {
            handler()
        } else if Thread.isMainThread {
            DispatchQueue.main.async {
                handler()
            }
        } else {
            // Execution is not on the main queue and thread at this point.
            // The sync operation will not block any.
            // It is important to perform an operation synchronously.
            // Otherwise, it can cause a race condition.
            DispatchQueue.main.sync {
                handler()
            }
        }
    }
}

// MARK: - Helpers
extension DispatchQueue {
    public static func toBackground(_ handler: @escaping VoidHandler) {
        DispatchQueue.global().async(execute: handler)
    }
    
    public static func delay(time: Double, handler: @escaping VoidHandler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: handler)
    }
}

// MARK: - current queue
extension DispatchQueue {
    static var currentQueueLabel: String? {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))
    }
    
    static var currentQueueLabelAsserted: String {
        guard let currentQueueLabel = currentQueueLabel else {
            assertionFailure("something went wrong with: \(__dispatch_queue_get_label(nil))")
            return ""
        }
        return currentQueueLabel
    }
}
