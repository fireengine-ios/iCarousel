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
    private var fileUuid: String = ""
    private var fileName: String = ""
    private let baseUrl = RouteRequests.onlyOfficeGetFile
    
    init(fileUuid: String, fileName: String) {
        self.fileName = fileName
        self.fileUuid = fileUuid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: fileName)
        onlyOfficeWebView.navigationDelegate = self
        configureWebView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if StringConstants.onlyOfficeCreateFile {
            StringConstants.onlyOfficeCreateFile = false
            NotificationCenter.default.post(name: .createOnlyOfficeDocumentsReloadData, object: nil)
        }
    }
    
    private func configureWebView() {
        
        var request = URLRequest(url: URL(string: "\(baseUrl)/\(fileUuid)")!)
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
        decisionHandler(.allow)
    }
}
