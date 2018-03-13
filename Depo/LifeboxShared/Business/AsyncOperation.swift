//
//  AsyncOperation.swift
//  Depo
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

/// https://habrahabr.ru/post/335756/
/// https://github.com/BestKora/Operation_OperatioQueue/blob/master/AsyncOperations.playground/Contents.swift
class AsyncOperation: Operation {
    
    // Определяем перечисление enum State со свойством keyPath
    public enum State {
        case ready
        case executing
        case finished
        
        fileprivate var keyPath: String {
            switch self {
            case .ready:
                return "isReady"
            case .executing: return
                "isExecuting"
            case .finished: return
                "isFinished"
            }
        }
    }
    
    // Помещаем в subclass свойство state типа State
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    func finish() {
        if isExecuting {
            state = .finished
        } else if isFinished {
            return
        } else {
            state = .executing
            state = .finished
        }
    }
}

extension AsyncOperation {
    // Переопределения для Operation
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            finish()
            return
        }
        if isFinished {
//            finish()
            return
        }
        
        state = .executing
        main()
    }
    
    override func cancel() {
        finish()
    }
}
