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
    private var acceptedCollectionViewNumberOfItem = 0
    private var accountBGColors = [UIColor]()
    private var invitationRegisteredResponse: InvitationRegisteredResponse?
    
    //MARK: -IBOutlet
    @IBOutlet private weak var copyLinkView: UIView! {
        willSet {
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = AppColor.darkBlueAndTealish.color.cgColor
        }
    }
    
    @IBOutlet private weak var campaignDetailLabel: UILabel! {
        willSet {
            newValue.text = localized(.paycellCampaignDetailTitle)
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
            newValue.isHidden = true
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
            newValue.text = localized(.paycellEarnedTitle)
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
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var earnedMoneySubtitle: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.numberOfLines = 2
            newValue.text = localized(.paycellEarnedSubtitle)
            newValue.font = .TurkcellSaturaFont(size: 14)
            newValue.minimumScaleFactor = 0.5
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var earnedMoneyStackView: UIStackView! {
        willSet {
            newValue.alignment = .center
            newValue.spacing = 4
        }
    }
    
    @IBOutlet private weak var seeAllButton: UIButton! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet private weak var acceptedInvitationTitle: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        fetchInitialState()
    }
    
    //MARK: -IBAction
    @IBAction func onShareLink(_ sender: UIButton) {
        guard let invitationLinkValue = linkLabel.text, let url =  URL(string: invitationLinkValue) else { return }

        let message = localized(.paycellShareMessage)
        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activityType, completed, _, _ in
            return
        }

        ///works only on iPad
        activityVC.popoverPresentationController?.sourceView = shareLinkButton
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func onSeeAllPeopleButton(_ sender: UIButton) {
        let acceptedInvitation = AcceptedInvitationViewController(invitationType: .paycell)
        self.navigationController?.pushViewController(acceptedInvitation, animated: true)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        shareLinkButton.setBackgroundColor(AppColor.darkBlueAndTealish.color , for: .normal)
        shareLinkButton.setBackgroundColor(AppColor.darkBlueAndTealish.color , for: .highlighted)
        copyLinkView.layer.borderColor = AppColor.darkBlueAndTealish.color.cgColor
    }
    
    //MARK: -Helpers
    private func changeState(hasLink: Bool) {
        DispatchQueue.main.async {
            self.shareLinkButton.isUserInteractionEnabled = hasLink
            self.linkLabel.isHidden = !hasLink
            self.copyLinkButton.isHidden = !hasLink
            self.createLinkButton.isHidden = hasLink
        }
    }
    
    private func showCampaignDetail(with model: PaycellDetailModel, type: PaycellDetailType) {
        let vc = router.paycellDetailPopup(with: model, type: type)
        vc.successCallback = { [weak self] in
            self?.getPaycellLink()
        }
        router.presentViewController(controller: vc)
    }
    
    private func showGain(with amount: Double?) {
        guard let amount = amount else {
            earnedMoneyLabel.text = "0 TL"
            return
        }
        
        let formattedPrice = amount.formatted
        earnedMoneyLabel.text = "\(formattedPrice) TL"
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
        components.uriPrefix = RouteRequests.appLinkDomain
        components.deepLink = deeplink
        components.iosBundleId = Bundle.main.bundleIdentifier
        components.iosDeepLink = deeplink
        components.androidDeepLink = deeplink
        components.androidPackageName = Device.androidPackageName
        components.previewType = .appInfo
        components.androidOpenType = .localMarket
        components.buildShortLink { shortLink, error in
            if error != nil {
                debugLog(error?.localizedDescription ?? "")
            }
            
            self.linkLabel.text = shortLink?.url.absoluteString
        }
    }
    
    private func configureAcceptedPeople(response: InvitationRegisteredResponse) {
        self.invitationRegisteredResponse = response
        acceptedCollectionViewNumberOfItem = response.accounts.count
        accountBGColors = AccountConstants.shared.generateBGColors(numberOfItems: response.accounts.count)
        acceptedInvitationTitle.text = String(format: localized(.paycellAcceptedFriends), response.totalAccount)
        collectionView.reloadData()
        seeAllButton.isHidden = response.accounts.count == 0
    }
    
    private func configureCollectionView() {
        collectionView.register(nibCell: InvitedPeopleCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchInitialState() {
        getPaycellLink()
        getPaycellGain()
        getAcceptedList()
    }
    
    private func configureUI() {
        setTitle(withString: localized(.paycellCampaignTitle))
        addGradient()
    }
}

//Interactor
extension PaycellCampaignViewController {
    private func getPaycellLink() {
        service.getPaycellLink { [weak self] result in
            switch result {
            case .success(let deeplink):
                self?.changeState(hasLink: true)
                self?.createAppLink(with: deeplink.link)
            case .failed(let error):
                if error.description == "CONSENT_REQUIRED" {
                    self?.changeState(hasLink: false)
                }
            }
        }
    }
    
    private func getPaycellDetail(for type: PaycellDetailType) {
        service.getPaycellDetail { [weak self] result in
            switch result {
            case .success(let response):
                self?.showCampaignDetail(with: response.value, type: type)
            case .failed(let error):
                UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
                debugLog("Paycell detail response error = \(error.description)")
            }
        }
    }
    
    private func getPaycellGain() {
        service.paycellGain { result in
            switch result {
            case .success(let response):
                self.showGain(with: response.result)
            case .failed(let error):
                debugLog("Paycell gain response error = \(error.description)")
            }
        }
    }
    
    private func getAcceptedList() {
        service.paycellAcceptedList(pageNumber: 0, pageSize: 5) { [weak self] result in
            switch result {
            case .success(let response):
                self?.configureAcceptedPeople(response: response)
            case .failed(let error):
                UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
                debugLog("Paycell Accepted response error = \(error.description)")
            }
        }
    }
}

//UICollectionViewDelegate
extension PaycellCampaignViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 71)
    }
}

//UICollectionViewDataSource
extension PaycellCampaignViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return acceptedCollectionViewNumberOfItem
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let invitationRegisteredAccount = self.invitationRegisteredResponse?.accounts[indexPath.item]
        let bgColor = self.accountBGColors[indexPath.item]

        let cell = collectionView.dequeue(cell: InvitedPeopleCollectionViewCell.self, for: indexPath)
        cell.configureCell(invitationRegisteredAccount: invitationRegisteredAccount!, bgColor: bgColor)
        return cell
    }
}
