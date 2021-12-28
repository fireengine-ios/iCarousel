//
//  InvitationCampaignDetailView.swift
//  Depo
//
//  Created by Alper Kırdök on 17.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class InvitationCampaignDetailView: UIView, NibInit {

    @IBOutlet weak var campaignDetailImageView: LoadingImageView!
    @IBOutlet weak var campaignDetailWebView: WKWebView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonBGView: UIView!

    private lazy var analyticsService: AnalyticsService = factory.resolve()

    override func awakeFromNib() {
        super.awakeFromNib()
        localizable()
        fetchCampaignDetail()
        self.analyticsService.logScreen(screen: .invitationCampaignDetail)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.InvitationCampaignDetailScreen())
    }

    func place(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupShadow()
    }

    private func setupShadow() {
        let shadowColor = UIColor(red: 126 / 255, green: 129 / 255, blue: 133 / 255, alpha:0.4)
        closeButtonBGView.layer.shadowColor = shadowColor.cgColor
        closeButtonBGView.layer.shadowOffset = CGSize(width: 0, height: -2)
        closeButtonBGView.layer.shadowOpacity = 1
        closeButtonBGView.layer.shadowRadius = 20
        closeButtonBGView.layer.masksToBounds = false
    }

    private func localizable() {
        closeButton.setTitle(TextConstants.accessibilityClose, for: .normal)
    }

    func fetchCampaignDetail() {
        let hexColor = AppColor.blackColor.color?.toHexString() ?? "#000000"
        self.showSpinner()
        InvitationApiService().getInvitationCampaign { result in
            self.hideSpinner()
            switch result {
            case .success(let response):
                self.setupViewWithObject(campaign: response, hexColor: hexColor)
            case .failed(let error):
                print("invitation campaign response error = \(error.description)")
            }
        }
    }

    private func setupViewWithObject(campaign: InvitationCampaignResponse, hexColor: String) {
        campaignDetailImageView.setLogs(enabled: true)
        let imageUrl = URL(string: campaign.value.image)
        campaignDetailImageView.loadImageData(with: imageUrl)
        let htmlString = prepareHtmlString(with: campaign.value.content, hexColor: hexColor)
        campaignDetailWebView.loadHTMLString(htmlString, baseURL: nil)
    }

    private func prepareHtmlString(with content: String, hexColor: String) -> String {
        var htmlString = content
        htmlString = "<style>" +
                "html *" +
                "{" +
                "color: \(hexColor)"  +
                "}</style> \(content)"
        return htmlString
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        fetchCampaignDetail()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        removeFromSuperview()
    }
}

extension InvitationCampaignDetailView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
