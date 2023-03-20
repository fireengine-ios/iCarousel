//
//  WebViewPopup.swift
//  Depo
//
//  Created by yilmaz edis on 13.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class WebViewPopup: BasePopUpController {
    
    private lazy var popUpView: UIView! = {
        let view = UIView()
        view.backgroundColor = AppColor.secondaryBackground.color
        view.layer.cornerRadius = 15
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(Image.iconCircleCancel.image, for: .normal)
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = true
        return view
    }()
    
    private var id: Int = 0
    private var isUrl = false
    private let service = NotificationService()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        closeButton.addTarget(self, action: #selector(closeOnTap), for: .touchUpInside)
    }
    
    @objc private func closeOnTap() {
        service.delete(with: [id]) { value in
            debugLog("WebViewPopup - Close - Success")
        } fail: { value in
            debugLog("WebViewPopup - Close - Fail")
        }
        close()
    }
    
    //MARK: Utility Method
    private func setup() {
        
        contentView = popUpView
        
        view.backgroundColor = AppColor.popUpBackground.color
        
        view.addSubview(popUpView)
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        
        popUpView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).activate()
        popUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).activate()
        popUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).activate()
        popUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).activate()
        
        popUpView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.pinToSuperviewEdges()
        
        popUpView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 16).activate()
        closeButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: -16).activate()
        closeButton.heightAnchor.constraint(equalToConstant: 24).activate()
        closeButton.widthAnchor.constraint(equalToConstant: 24).activate()
    }
}

//MARK: - Init
extension WebViewPopup {
    private static func raiseWebView(controller: WebViewPopup, url: String) {
        // Create a new URL object with the URL you want to load
        let url = URL(string: url)!

        // Create a new URLRequest object with the URL
        let request = URLRequest(url: url)

        // Load the URL request in the WKWebView
        controller.webView.load(request)
    }
    
    private static func raiseHtml(controller: WebViewPopup, content: String) {
        // will be developed after notification body is ready!
    }
    
    static func with(content: String, id: Int, isUrl: Bool) -> WebViewPopup {
        let controller = WebViewPopup()
        
        controller.isUrl = isUrl
        controller.id = id
        
        if isUrl {
            raiseWebView(controller: controller, url: content)
        } else {
            raiseHtml(controller: controller, content: content)
        }

        return controller
    }
}
