//
//  ChatbotViewController.swift
//  Depo
//
//  Created by Alper Kırdök on 8.06.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class ChatbotViewController: BaseViewController {

    @IBOutlet weak var chatbotWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(withString: TextConstants.chatbotMenuTitle)
        chatbotWebView.navigationDelegate = self
        clearWKWbView()
        getTicket()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.ChatbotScreen())
        AnalyticsService().logScreen(screen: .chatbot)
    }

    private func getTicket() {
        self.showSpinner()
        AccountService().getAccountTicket { [weak self] result in
            defer { self?.hideSpinner() }
            switch result {
            case .success(let response):
                self?.configureWebView(with: response.ticket)
            case .failed(let error):
                print("GetTicket response error = \(error.description)")
            }
        }
    }

    private func clearWKWbView() {
        chatbotWebView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
    }

    private func configureWebView(with token: String) {
        guard let cookie = HTTPCookie(properties: [
            .domain: RouteRequests.chatbotCookieDomain,
            .path: "/",
            .name: "X-Auth-Token",
            .value: token,
            .secure: "true",
            .expires: NSDate(timeIntervalSinceNow: 30),
            .httpOnly: true
        ]) else { return }

        self.chatbotWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
            self.chatbotWebView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                let request = URLRequest(url: self.url)
                self.chatbotWebView.load(request)
            }
        }
    }

    private var url: URL {
        let baseURL = RouteRequests.chatbotBaseDomain
        let src = "lifebox"
        let type = "ios"

        var client = ""
        if let deviceId = Device.deviceId {
            client = deviceId
        }

        var version = "1.0"
        if let versionTemp = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            version = versionTemp
        }

        let language = Device.locale
        let theme = "light"

        let url = URL(string: baseURL + "client=\(client)&lang=\(language)&version=\(version)&type=\(type)&src=\(src)&theme=\(theme)")!

        return url
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChatbotViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            decisionHandler(.cancel)
            return
        } else if let url = navigationAction.request.url {
            if let host = url.host {
                if !host.lowercased().hasPrefix(RouteRequests.chatbotCookieDomain) {
                    if let scheme = url.scheme {
                        if scheme.lowercased().contains("akillidepo") || scheme.lowercased().contains("http") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:])
                            }
                            decisionHandler(.cancel)
                            return
                        }
                    }
                }
            }
        }

        decisionHandler(.allow)
    }
}

extension HTTPCookiePropertyKey {
    static let httpOnly = HTTPCookiePropertyKey("HttpOnly")
}
