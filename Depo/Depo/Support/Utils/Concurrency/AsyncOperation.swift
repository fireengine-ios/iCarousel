//
//  AsyncOperation.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/22/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

open class AsyncOperation: Operation {
    public enum State {
        case ready
        case executing
        case finished
        
        fileprivate var key: String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            }
        }
    }
    
    fileprivate(set) public var state = State.ready {
        willSet {
            willChangeValue(forKey: state.key)
            willChangeValue(forKey: newValue.key)
        }
        didSet {
            didChangeValue(forKey: oldValue.key)
            didChangeValue(forKey: state.key)
        }
    }
    
    final override public var isAsynchronous: Bool {
        return true
    }
    
    final override public var isExecuting: Bool {
        return state == .executing
    }
    
    final override public var isFinished: Bool {
        return state == .finished
    }
    
    final override public var isReady: Bool {
        return state == .ready
    }
    
    final func markFinished() {
        state = .finished
    }
    
    open func workItem() {
        markFinished()
    }
    
    final override public func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
    }
    
    final override public func main() {
        if isCancelled {
            state = .finished
            return
        }
        
        state = .executing
        workItem()
    }
}
