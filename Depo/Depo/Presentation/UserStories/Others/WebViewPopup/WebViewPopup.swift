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
    
    enum PopupType {
        case webView
        case html
        case string
    }
    
    private lazy var popUpView: UIView! = {
        let view = UIView()
        view.backgroundColor = AppColor.collageThumbnailColor.color
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
    
    // MARK: - webView
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = true
        return view
    }()
    
    // MARK: - Html
    
    private lazy var bodyScrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var bodyLabel: UITextView = {
        let view = UITextView()
        view.textColor = AppColor.textButton.color
        view.font = .appFont(.regular, size: 16)
        view.textAlignment = .natural
        view.dataDetectorTypes = .all
        view.isEditable = false
        view.isSelectable = true
        view.isScrollEnabled = false
        return view
    }()
    
    // MARK: - String
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = AppColor.textButton.color
        view.font = .appFont(.medium, size: 20)
        view.textAlignment = .center
        view.numberOfLines = 1
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var cardImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var okButton: DarkBlueButton = {
        let view = DarkBlueButton()
        view.setTitle(TextConstants.ok, for: .normal)
        return view
    }()
    
    private var id: Int = 0
    private var type: PopupType = .webView
    private let service = NotificationService()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        closeButton.addTarget(self, action: #selector(closeOnTap), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(closeOnTap), for: .touchUpInside)
    }
    
    @objc private func closeOnTap() {
        sendRead()
        close()
    }
    
    //MARK: Utility Method
    private func setup() {
        contentView = popUpView
        view.backgroundColor = AppColor.popUpBackground.color
        
        view.addSubview(popUpView)
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case.string:
            setForStringLayout()
        case.html:
            setForHtmlLayout()
        case.webView:
            setForWebViewLayout()
        }
        
        popUpView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 16).activate()
        closeButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: -16).activate()
        closeButton.heightAnchor.constraint(equalToConstant: 24).activate()
        closeButton.widthAnchor.constraint(equalToConstant: 24).activate()
        
        bodyLabel.backgroundColor = AppColor.collageThumbnailColor.color
    }
    
    private func setForWebViewLayout() {
        popUpView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).activate()
        popUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).activate()
        popUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).activate()
        popUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).activate()
        
        popUpView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.pinToSuperviewEdges()
    }
    
    private func setForHtmlLayout() {
        popUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor).activate()
        popUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).activate()
        popUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).activate()
        
        let height = getHightOfLabel()
        if height > UIScreen.main.bounds.height - 160 {
            bodyScrollView.isScrollEnabled = true
            popUpView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 160).activate()
        } else {
            bodyScrollView.isScrollEnabled = false
            popUpView.heightAnchor.constraint(equalToConstant: height).activate()
        }
        
        let contentView = UIView()
        popUpView.addSubview(bodyScrollView)
        bodyScrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        bodyScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        bodyScrollView.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        bodyScrollView.widthAnchor.constraint(equalTo: popUpView.widthAnchor).isActive = true
        bodyScrollView.topAnchor.constraint(equalTo: popUpView.topAnchor).isActive = true
        bodyScrollView.bottomAnchor.constraint(equalTo: popUpView.bottomAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: bodyScrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: bodyScrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: bodyScrollView.topAnchor, constant: 15).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bodyScrollView.bottomAnchor, constant: -20).isActive = true

        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        bodyLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 7/8).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
    }
    
    private func setForStringLayout() {
        popUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        popUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).activate()
        popUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).activate()
        
        popUpView.addSubview(titleLabel)
        popUpView.addSubview(bodyScrollView)
        popUpView.addSubview(cardImageView)
        popUpView.addSubview(okButton)
        
        let height = getHightOfLabel()
        if height > 400 {
            bodyScrollView.isScrollEnabled = true
            bodyScrollView.heightAnchor.constraint(equalToConstant: 400).activate()
        } else {
            bodyScrollView.isScrollEnabled = false
            bodyScrollView.heightAnchor.constraint(equalToConstant: height).activate()
        }
        
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 16).activate()
        cardImageView.heightAnchor.constraint(equalToConstant: 44).activate()
        cardImageView.widthAnchor.constraint(equalToConstant: 44).activate()
        cardImageView.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).activate()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 12).activate()
        titleLabel.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).activate()
        
        ///
        let contentView = UIView()
        bodyScrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        bodyScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        bodyScrollView.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        bodyScrollView.widthAnchor.constraint(equalTo: popUpView.widthAnchor).isActive = true
        bodyScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        contentView.centerXAnchor.constraint(equalTo: bodyScrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: bodyScrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: bodyScrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bodyScrollView.bottomAnchor).isActive = true

        contentView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        bodyLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 7/8).isActive = true
        bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        ///
        
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.topAnchor.constraint(equalTo: bodyScrollView.bottomAnchor, constant: 16).activate()
        okButton.bottomAnchor.constraint(equalTo: popUpView.bottomAnchor, constant: -30).activate()
        okButton.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 75).activate()
        okButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: -75).activate()
        okButton.heightAnchor.constraint(equalToConstant: 45).activate()
        
        closeButton.isHidden = true
    }
    
    private func sendRead() {
        service.read(with: String(id)) { value in
            debugLog("WebViewPopup - Close - Success")
        } fail: { value in
            debugLog("WebViewPopup - Close - Fail")
        }
    }
    private func getHightOfLabel() -> CGFloat {
        // Subsract leadind and trailings
        let width = UIScreen.main.bounds.width - 24
        
        // this is better than string extension hight
        let height = bodyLabel.systemLayoutSizeFitting(CGSize(width: width,
                                                                     height: UIView.layoutFittingCompressedSize.height),
                                                              withHorizontalFittingPriority: .required,
                                                              verticalFittingPriority: .fittingSizeLevel).height
        // Plus top and bottom constraint
        return height + 67
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
    
    private static func raiseString(controller: WebViewPopup, content: NotificationServiceResponse) {
        guard let body = content.body,
              let title = content.title else { return }
        
        if body.isHTMLString {
            controller.type = .html
            controller.bodyLabel.attributedText = body.getAsHtml
        } else {
            controller.type = .string
            controller.bodyLabel.text = body
            controller.titleLabel.text = title
            
            if let imageUrl = content.image ?? content.smallThumbnail ?? content.largeThumbnail,
                let url = URL(string: imageUrl) {
                controller.cardImageView.sd_setImage(with: url)
            }
        }
    }
    
    static func with(content: NotificationServiceResponse) -> WebViewPopup {
        let controller = WebViewPopup()
        
        controller.id = content.communicationNotificationId ?? 0
                
        if let url = content.url {
            raiseWebView(controller: controller, url: url)
        } else {
            raiseString(controller: controller, content: content)
        }

        return controller
    }
}
