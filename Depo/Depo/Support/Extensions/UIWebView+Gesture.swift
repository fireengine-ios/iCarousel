//
//  UIWebView+Gesture.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIWebView {
    /// Usage
    /**
    save gesture
     
     if let zoomGesture = webView.doubleTapZoomGesture {
        doubleTapWebViewGesture = zoomGesture
        tapGesture.require(toFail: zoomGesture)
     }
     
    add UIGestureRecognizerDelegate
     
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGesture, otherGestureRecognizer == doubleTapWebViewGesture {
            return false
        }
        return true
     }
    */
    var doubleTapZoomGesture: UITapGestureRecognizer? {
        for view in scrollView.subviews {
            guard String(describing: view.classForCoder) == "UIWebBrowserView",
                let gestures = view.gestureRecognizers
                else { continue }
            
            for gesture in gestures {
                if let gesture = gesture as? UITapGestureRecognizer, gesture.numberOfTapsRequired == 2 {
                    return gesture
                }
            }
        }
        return nil
    }
}
