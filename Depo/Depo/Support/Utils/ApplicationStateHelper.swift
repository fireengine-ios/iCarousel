//
//  ApplicationStateHelper.swift
//  Depo
//
//  Created by Alex on 2/12/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class ApplicationStateHelper {
    
    static let shared = ApplicationStateHelper()
    
    var state: UIApplication.State {
        #if DEBUG
        if !DispatchQueue.isMainQueue || !Thread.isMainThread {
            assertionFailure("👉 CALL THIS FROM MAIN THREAD")
        }
        #endif
        return UIApplication.shared.applicationState
    }
    
    var safeApplicationState: UIApplication.State {
        let semaphore = DispatchSemaphore(value: 0)
        var state: UIApplication.State = .background
        applicationState { appState in
            state = appState
            semaphore.signal()
        }
        semaphore.wait()
        return state
    }
    
    var isBackground: Bool {
        return safeApplicationState == .background
    }
    
    func applicationState(stateCallback: @escaping (UIApplication.State) -> Void)  {
        DispatchQueue.toMain {
            stateCallback(self.state)
        }
    }
}
