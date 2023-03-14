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
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(Image.iconCancelUnborder.image, for: .normal)
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = true
        return view
    }()

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeOnTap))
        view.addGestureRecognizer(recognizer)
        
        closeButton.addTarget(self, action: #selector(closeOnTap), for: .touchUpInside)
    }
    
    @objc private func closeOnTap() {
        close()
    }
    
    //MARK: Utility Method
    private func setup() {
        
        contentView = popUpView
        
        view.backgroundColor = AppColor.popUpBackground.color
        
        view.addSubview(popUpView)
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).activate()
        popUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).activate()
        popUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).activate()
        popUpView.heightAnchor.constraint(equalToConstant: 300).activate()
        
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
    
    static func with(url: String) -> WebViewPopup {
        let controller = WebViewPopup()

        // Create a new URL object with the URL you want to load
        let url = URL(string: url)!

        // Create a new URLRequest object with the URL
        let request = URLRequest(url: url)

        // Load the URL request in the WKWebView
        controller.webView.load(request)

        return controller
    }
}
