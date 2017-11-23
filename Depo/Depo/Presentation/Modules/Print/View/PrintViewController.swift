//
//  PrintViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrintViewController: UIViewController {
    
    @IBOutlet private weak var webView: UIWebView!

    var output: PrintViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarWithGradientStyle()
        output.viewIsReady()
    }
    
}

// MARK: - PrintInteractorOutput

extension PrintViewController: PrintViewInput {
    
    func loadUrl(_ urlRequest: URLRequest) {
        webView.loadRequest(urlRequest)
    }

}

// MARK: - PrintInteractorOutput

extension PrintViewController: UIWebViewDelegate {
   
    func webViewDidStartLoad(_ webView: UIWebView) {
        output.didStartLoad()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        output.didEndLoad()
    }
    
}
