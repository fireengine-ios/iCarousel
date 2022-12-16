//
//  InvitationViewController.swift
//  Depo_LifeTech
//
//  Created by Alper Kırdök on 3.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class InvitationViewController: BaseViewController {

    @IBOutlet weak var invitationCollectionView: UICollectionView!

    private var invitationLink: InvitationLink?
    private var invitationRegistered: InvitationRegisteredResponse?
    private var invitationGiftList: [SubscriptionPlanBaseResponse] = []
    private var invitationSubscriptionPlanList: [SubscriptionPlan] = []
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var invitationRegisteredResponse: InvitationRegisteredResponse?
    private var campaignDetail: InvitationCampaignResponse?
    private var acceptedCollectionViewNumberOfItem = 0
    private var isDetailShown = false
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var linkView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet weak var giftsView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet weak var campaignDetailView: UIStackView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet weak var campaignDetailLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.titleInvitationCampaign
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = AppColor.label.color
        }
    }

    @IBOutlet weak var invitationLinkTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.titleInvitationLink
            newValue.textColor = AppColor.label.color
            newValue.font = UIFont.appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var invitationLinkLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = UIFont.appFont(.bold, size: 10)
        }
    }
    
    @IBOutlet weak var invitationLinkShareButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(TextConstants.invitationShare, for: .normal)
        }
    }
    
    @IBOutlet weak var copyLinkBGView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.campaignBackground.color
        }
    }

    @IBOutlet weak var acceptedInvitationTitleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.campaignDarkLabel.color
            newValue.font = UIFont.appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet weak var acceptedInvitationListCollectionView: UICollectionView!
    @IBOutlet weak var invitationListButton: UIButton!
    @IBOutlet weak var showCampaignDetailButton: UIButton!
    
    @IBOutlet weak var giftsTitleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.campaignDarkLabel.color
            newValue.font = UIFont.appFont(.medium, size: 14)
        }
    }

    @IBOutlet weak var campaignContentLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.textColor = AppColor.campaignContentLabel.color
            newValue.font = .appFont(.medium, size: 12)
            newValue.isHidden = true
        }
    }
    
    let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.settingsItemInvitation)
        setupCollectionView()

        fetchInvitationLink()
        fetchInvitationAcceptedList()
        fetchInvitationSubscriptionList()
        fetchCampaignDetail()

        group.notify(queue: .main) {
            self.invitationCollectionView.reloadData()
            self.invitationCollectionView.collectionViewLayout.invalidateLayout()
            self.configureUI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.InvitationScreen())
        self.analyticsService.logScreen(screen: .invitation)
    }

    private func setupCollectionView() {
        invitationCollectionView.register(nibCell: InvitationGiftCollectionViewCell.self)
        acceptedInvitationListCollectionView.delegate = self
        acceptedInvitationListCollectionView.dataSource = self
        acceptedInvitationListCollectionView.register(nibCell: InvitedPeopleCollectionViewCell.self)
    }
    
    private func configureUI() {
        if let invitationLink = self.invitationLink {
            configureLinkView(invitationLink: invitationLink)
        }

        if let invitationRegistered = self.invitationRegistered {
            configureInvitationRegisteredView(invitationRegisteredResponse: invitationRegistered)
        }

        configureGiftList(invitationGiftList: self.invitationGiftList)
    }
    
    private func makingSubscriptionPlanObject() {
        self.invitationSubscriptionPlanList = PackageService().convertToSubscriptionPlan(offers: self.invitationGiftList, accountType: .all)
    }
    
    func configureLinkView(invitationLink: InvitationLink) {
        self.invitationLink = invitationLink
        invitationLinkLabel.text = invitationLink.url
    }
    
    func configureInvitationRegisteredView(invitationRegisteredResponse: InvitationRegisteredResponse) {
        self.invitationRegisteredResponse = invitationRegisteredResponse
        calculateNumberOfItems(invitationRegisteredResponse: invitationRegisteredResponse)
        acceptedInvitationTitleLabel.text = String(format: TextConstants.titleInvitationFriends, self.invitationRegisteredResponse?.totalAccount ?? 0)
        acceptedInvitationListCollectionView.reloadData()
        invitationListButton.isHidden = invitationRegisteredResponse.accounts.count == 0
    }

    func configureGiftList(invitationGiftList: [SubscriptionPlanBaseResponse]) {
        giftsTitleLabel.text = String(format: TextConstants.titleInvitationPackages, invitationGiftList.count)
    }

    func calculateNumberOfItems(invitationRegisteredResponse: InvitationRegisteredResponse) {
        if invitationRegisteredResponse.accounts.count > maxShownNumberOfItem {
            acceptedCollectionViewNumberOfItem = maxShownNumberOfItem
        } else {
            acceptedCollectionViewNumberOfItem = invitationRegisteredResponse.accounts.count
        }
    }

    var maxShownNumberOfItem: Int {
        let collectionViewWidth = acceptedInvitationListCollectionView.bounds.width
        let cellWidthWithSpace: CGFloat = 95

        return Int(collectionViewWidth / cellWidthWithSpace)
    }
    
    @IBAction func onLinkCopyButton(_ sender: UIButton) {
        self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: .invitation(.copyInvitationLink))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .copyInvitationLink))

        guard let invitatonLink = self.invitationLink else { return }

        guard invitatonLink.shareable else {
            let message = TextConstants.invitationSnackbarCopyExceed
            SnackbarManager.shared.show(type: SnackbarType.action, message: message)
            return
        }

        UIPasteboard.general.string = invitatonLink.url

        let message = TextConstants.invitationSnackbarCopy
        SnackbarManager.shared.show(type: SnackbarType.action, message: message)
    }
    
    @IBAction func onLinkShareButton(_ sender: DarkBlueButton) {
        guard let invitatonLink = self.invitationLink else { return }

        guard invitatonLink.shareable else {
            let message = TextConstants.invitationSnackbarShareExceed
            SnackbarManager.shared.show(type: SnackbarType.action, message: message)
            return
        }

        invitationShareLink(shareButton: invitationLinkShareButton)
    }
    
    @IBAction func onInvitationListButton(_ sender: UIButton) {
        invitationListButtonTapped()
    }
    
    @IBAction func onCampaignDetailButton(_ sender: UIButton) {
        isDetailShown = !isDetailShown

        UIView.transition(with: campaignContentLabel, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.showCampaignDetailButton.transform = self.showCampaignDetailButton.transform.rotated(by: .pi)
            self.campaignContentLabel.isHidden = !self.isDetailShown
        })
    }
                              
    private func setupViewWithObject(campaign: InvitationCampaignResponse) {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .light {
                let hexColor = AppColor.campaignContentLabel.color.toHexString()
                campaignContentLabel.attributedText = campaign.value.content.convertHtmlToAttributedStringWithCSS(font: .appFont(.medium, size: 12), csscolor: hexColor, lineheight: 5, csstextalign: "left")
            } else {
                let hexColor = "#ECECEC"
                campaignContentLabel.attributedText = campaign.value.content.convertHtmlToAttributedStringWithCSS(font: .appFont(.medium, size: 12), csscolor: hexColor, lineheight: 5, csstextalign: "left")
            }
        } else if #available(iOS 16.1, *) {
            if self.traitCollection.userInterfaceStyle == .light {
                let hexColor = AppColor.campaignContentLabel.color.toHexString()
                campaignContentLabel.attributedText = campaign.value.content.convertHtmlToAttributedStringWithCSS(font: .appFont(.medium, size: 12), csscolor: hexColor, lineheight: 5, csstextalign: "left")
            } else {
                let hexColor = "#ECECEC"
                campaignContentLabel.attributedText = campaign.value.content.convertHtmlToAttributedStringWithCSS(font: .appFont(.medium, size: 12), csscolor: hexColor, lineheight: 5, csstextalign: "left")
            }
        } else {
            let hexColor = "#ECECEC"
            campaignContentLabel.attributedText = campaign.value.content.convertHtmlToAttributedStringWithCSS(font: .appFont(.medium, size: 12), csscolor: hexColor, lineheight: 5, csstextalign: "left")
        }
//        let data = Data(campaign.value.content.utf8)
//
//        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
//
//            campaignContentLabel.attributedText = attributedString
//            campaignContentLabel.textColor = AppColor.campaignContentLabel.color
//            campaignContentLabel.font = UIFont.appFont(.medium, size: 12)
//        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let campaignDetail = campaignDetail else { return }
        DispatchQueue.main.async {
            self.setupViewWithObject(campaign: campaignDetail)
        }
    }
}

//Interactor
extension InvitationViewController {
    func fetchInvitationLink() {
        group.enter()
        InvitationApiService().getInvitationLink { [weak self] result in
            defer { self?.group.leave() }
            switch result {
            case .success(let response):
                self?.invitationLink = response
            case .failed(let error):
                print("invitation response error = \(error.description)")
            }
        }
    }

    func fetchInvitationAcceptedList() {
        group.enter()
        InvitationApiService().getInvitationList(pageNumber: 0, pageSize: 10) { [weak self] result in
            defer { self?.group.leave() }
            switch result {
            case .success(let response):
                self?.invitationRegistered = response
            case .failed(let error):
                print("invitation Accepted response error = \(error.description)")
            }
        }
    }

    func fetchInvitationSubscriptionList() {
        group.enter()
        InvitationApiService().getInvitationSubscriptions(
            success: { [weak self] response in
                guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else { return }
                self?.invitationGiftList = subscriptionsResponse.list
                self?.makingSubscriptionPlanObject()
                self?.group.leave()
            }, fail: { errorResponse in
                self.group.leave()
            })
    }
    
    func fetchCampaignDetail() {
        self.showSpinner()
        InvitationApiService().getInvitationCampaign { result in
            self.hideSpinner()
            switch result {
            case .success(let response):
                self.campaignDetail = response
                self.setupViewWithObject(campaign: response)
            case .failed(let error):
                print("invitation campaign response error = \(error.description)")
            }
        }
    }
}

extension InvitationViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == invitationCollectionView {
            return CGSize(width: 128, height: 137);
        } else {
            return CGSize(width: 55, height: 100)
        }
    }
}

extension InvitationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == invitationCollectionView {
            return self.invitationSubscriptionPlanList.count
        } else {
            return acceptedCollectionViewNumberOfItem
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == invitationCollectionView {
            let subscriptionPlan = self.invitationSubscriptionPlanList[indexPath.item]
            let cell = collectionView.dequeue(cell: InvitationGiftCollectionViewCell.self, for: indexPath)
            cell.configureCell(subscriptionPlan: subscriptionPlan)
            return cell
        } else {
            let invitationRegisteredAccount = self.invitationRegisteredResponse?.accounts[indexPath.item]
            let cell = collectionView.dequeue(cell: InvitedPeopleCollectionViewCell.self, for: indexPath)
            cell.configureCell(invitationRegisteredAccount: invitationRegisteredAccount!)
            return cell
        }
    }
}

extension InvitationViewController {
    func invitationListButtonTapped() {
        let acceptedInvitation = AcceptedInvitationViewController()
        self.navigationController?.pushViewController(acceptedInvitation, animated: true)
    }

    func invitationCampaignDetail() {
        let invitationCampaignDetailView: InvitationCampaignDetailView = .initFromNib()
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        invitationCampaignDetailView.place(in: window)
    }

    func invitationShareLink(shareButton: UIButton) {

        self.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .share, eventLabel: .invitation(.invitationLink))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .share))

        guard let invitationLinkValue = self.invitationLink?.url, let url =  URL(string: invitationLinkValue) else { return }

        let message = TextConstants.invitationShareMessage

        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activityType, completed, _, _ in
            guard completed, let activityTypeString = activityType?.rawValue else {
                return
            }

            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Share(method: .invitationLink, channelType: activityTypeString.knownAppName()))
        }

        ///works only on iPad
        activityVC.popoverPresentationController?.sourceView = shareButton

        self.present(activityVC, animated: true, completion: nil) ///routerVC not work
    }
}


