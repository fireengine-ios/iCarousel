//
//  OnlyOfficeViewController.swift
//  Depo
//
//  Created by Ozan Salman on 6.04.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import WebKit

final class OnlyOfficeViewController: BaseViewController {
    
    @IBOutlet weak var onlyOfficeWebView: WKWebView!
    private let tokenStorage: TokenStorage = factory.resolve()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: "testWord.docx")
        onlyOfficeWebView.navigationDelegate = self
        configureWebView()
    }
    
    private func configureWebView() {
        
        var request = URLRequest(url: URL(string:"https://adepodev.turkcell.com.tr/api/office/files/4eaf8131-ffbc-4f24-867f-f4e4e9c2e9d1")!)
        request.allHTTPHeaderFields = self.authification()
        self.onlyOfficeWebView.load(request)
    }
    
    func base() -> RequestHeaderParametrs {
        return [ HeaderConstant.Accept      : "text/html",
                 HeaderConstant.ContentType : HeaderConstant.ApplicationJsonUtf8]
    }
    
    func authification() -> RequestHeaderParametrs {
        var result = base()
        if let accessToken = tokenStorage.accessToken {
            result = result + [HeaderConstant.AuthToken: accessToken]
        }
        return result
    }
}

extension OnlyOfficeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("aaaaaaaaaaaaaaaa \(navigationAction.request.url)")
        print("aaaaaaaaaaaaaaaa \(navigationAction.request)")
        decisionHandler(.allow)

    }
}
