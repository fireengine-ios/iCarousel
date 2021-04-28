//
//  WKWebView+Extensions.swift
//  Depo
//
//  Created by Konstantin on 6/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    func clearPage() {
        guard let url = URL(string: "about:blank") else {
            return
        }
        load(URLRequest(url: url))
    }
    
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
