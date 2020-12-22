//
//  HomePagePopUpOperation.swift
//  Depo
//
//  Created by Raman Harhun on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class HomePagePopUpOperation: Operation {
    
    private var router = RouterVC()
    var popUp: BasePopUpController?
    
    private var wasPresented = false
    
    private var semaphore = DispatchSemaphore(value: 0)
    
    override func main() {
        presentPopUp()
        
        semaphore.wait()
    }
    
    private func presentPopUp() {
        guard let popUp = popUp else {
            return
        }
        
        popUp.dismissCompletion = { [weak self] in
            self?.semaphore.signal()
        }
        
        DispatchQueue.main.async {
            /// open only on home page!
            /// if no, then operation will wait (because of wasPresented flag) till continueAfterPush which calls on HomePageViewController viewDidAppear
            let isHomePage = (self.router.defaultTopController as? TabBarViewController)?.currentViewController is HomePageViewController
            let isSpotlightPresentedOnHomePage = self.router.defaultTopController is SpotlightViewController
            if isHomePage || isSpotlightPresentedOnHomePage {
                self.router.defaultTopController?.present(popUp, animated: true) { [weak self] in
                    self?.wasPresented = true
                }
            }
        }
        
    }
    
    func continueAfterPush() {
        /// if popUp was presented then we just mark this operation is finished
        if wasPresented {
            semaphore.signal()
            
        } else {
            /// if something went wrong (f.e. we left homePageController)
            presentPopUp()
            
        }
    }
}
