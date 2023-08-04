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
    private let service = OnlyOfficeService()
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
        getFileHtml()
    }
    
    private func getFileHtml() {
        let fileUrl = "\(baseUrl)/\(fileUuid)"
        service.getOnlyOfficeFileHtml(fileUrl: fileUrl) { [weak self] result in
            switch result {
            case .success(let string):
                self?.onlyOfficeWebView.loadHTMLString(string, baseURL: URL(string: RouteRequests.baseShortUrlString))
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

extension OnlyOfficeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
