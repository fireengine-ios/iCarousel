//
//  PaycellCampaignViewController.swift
//  Depo
//
//  Created by Burak Donat on 6.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import AGConnectAppLinking

class PaycellCampaignViewController: BaseViewController {
    
    //MARK: -Properties
    private let service = PaycellCampaignService()
    private let router = RouterVC()
    
    //MARK: -IBOutlet
    @IBOutlet private weak var copyLinkView: UIView! {
        willSet {
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.darkBlueAndTealish.color?.cgColor
        }
    }
    
    @IBOutlet private weak var campaignDetailLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.titleInvitationCampaign
            newValue.textColor = .lrBrownishGrey
            newValue.font = .TurkcellSaturaFont(size: 18)
        }
    }
    
    @IBOutlet private weak var shareLinkButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.invitationShare, for: .normal)
            newValue.setBackgroundColor(AppColor.darkBlueAndTealish.color ?? ColorConstants.navy, for: .normal)
            newValue.setBackgroundColor(AppColor.darkBlueAndTealish.color ?? ColorConstants.navy, for: .highlighted)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .highlighted)
        }
    }
    
    @IBOutlet private weak var copyLinkButton: UIButton! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var createLinkButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.navyAndWhite.color, for: .normal)
            newValue.setTitle(localized(.paycellCreateLink), for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }
    
    @IBOutlet private weak var linkLabel: UILabel! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var linkTitleLabel: UILabel! {
        willSet {
            newValue.text = localized(.paycellLinkTitle)
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var earnedMoneyTitle: UILabel! {
        willSet {
            newValue.text = "Kazandığın TL"
            newValue.textColor = .lrBrownishGrey
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
        }
    }
    
    @IBOutlet private weak var earnedMoneyView: UIView! {
        willSet {
            newValue.backgroundColor = .lrTealishTwo
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet private weak var earnedMoneyLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.numberOfLines = 2
            newValue.text = "0 TL"
            newValue.font = .TurkcellSaturaBolFont(size: 18)
            newValue.minimumScaleFactor = 0.5
        }
    }
    
    @IBOutlet private weak var paycellGiftTitle: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.numberOfLines = 2
            newValue.text = "Paycell Hediyesi"
            newValue.font = .TurkcellSaturaFont(size: 14)
            newValue.minimumScaleFactor = 0.5
        }
    }
    
    @IBOutlet private weak var earnedMoneyStackView: UIStackView! {
        willSet {
            newValue.alignment = .center
            newValue.spacing = 4
        }
    }
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarWithGradientStyle(isHidden: false, hideLogo: true)
        setTitle(withString: localized(.paycellCampaignTitle))
        getPaycellLink()
        addGradient()
    }
    
    //MARK: -IBAction
    @IBAction func onShareLink(_ sender: UIButton) {
        
    }
    
    @IBAction func onCreateLink(_ sender: UIButton) {
        getPaycellDetail(for: .approval)
    }
    
    @IBAction func onCampaignDetailButton(_ sender: UIButton) {
        getPaycellDetail(for: .detail)
    }
    
    @IBAction func onCopyLink(_ sender: UIButton) {
        if linkLabel.text == "" {
            return
        }

        UIPasteboard.general.string = linkLabel.text

        let message = TextConstants.invitationSnackbarCopy
        SnackbarManager.shared.show(type: SnackbarType.action, message: message)
    }
    
    //MARK: -Helpers
    private func getPaycellLink() {
        service.getPaycellLink { result in
            switch result {
            case .success(let deeplink):
                self.changeState(hasLink: true)
                self.createAppLink(with: deeplink.link)
            case .failed(let error):
                if error.description == "CONSENT_REQUIRED" {
                    self.changeState(hasLink: false)
                }
            }
        }
    }
    
    private func getPaycellDetail(for type: PaycellDetailType) {
        service.getPaycellDetail { result in
            switch result {
            case .success(let response):
                self.showCampaignDetail(with: response.value, type: type)
            case .failed(_):
                break
            }
        }
    }
    
    private func changeState(hasLink: Bool) {
        shareLinkButton.isUserInteractionEnabled = hasLink
        linkLabel.isHidden = !hasLink
        copyLinkButton.isHidden = !hasLink
        createLinkButton.isHidden = hasLink
    }
    
    private func showCampaignDetail(with model: PaycellDetailModel, type: PaycellDetailType) {
        let vc = router.paycellDetailPopup(with: model, type: type)
        router.presentViewController(controller: vc) {
            self.getPaycellLink()
        }
    }
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.lrTealishTwo.cgColor, UIColor.lrGreyish.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = self.earnedMoneyView.bounds
        
        earnedMoneyView.layer.insertSublayer(gradientLayer, at:0)
        earnedMoneyView.layer.cornerRadius = earnedMoneyView.frame.height / 2
    }
    
    private func createAppLink(with deeplink: String) {
        let components = AGCAppLinkingComponents()
        components.uriPrefix = "https://mylifeboxpaycell.dre.agconnect.link"
        components.deepLink = deeplink
        components.iosBundleId = Bundle.main.bundleIdentifier
        components.iosDeepLink = deeplink
        components.androidDeepLink = deeplink
        components.androidPackageName = Device.androidPackageName
        components.previewType = .appInfo
        components.buildShortLink { shortLink, error in
            if error != nil {
                print(error)
            }
            
            self.linkLabel.text = shortLink?.url.absoluteString
        }
    }
}
