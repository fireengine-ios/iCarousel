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

    let group = DispatchGroup()
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.settingsItemInvitation)
        setupCollectionView()

        fetchInvitationLink()
        fetchInvitationAcceptedList()
        fetchInvitationSubscriptionList()

        group.notify(queue: .main) {
            self.invitationCollectionView.reloadData()
            self.invitationCollectionView.collectionViewLayout.invalidateLayout()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.InvitationScreen())
        self.analyticsService.logScreen(screen: .invitation)
    }

    private func setupCollectionView() {
        invitationCollectionView.register(UINib(nibName: InvitationCollectionReusableView.reuseId, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: InvitationCollectionReusableView.reuseId)
        invitationCollectionView.register(nibCell: InvitationGiftCollectionViewCell.self)
    }

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

    private func makingSubscriptionPlanObject() {
        self.invitationSubscriptionPlanList = PackageService().convertToSubscriptionPlan(offers: self.invitationGiftList, accountType: .all)
    }
}

extension InvitationViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 75);
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: ScreenConstants.screenWidth, height: 388);
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InvitationCollectionReusableView.reuseId, for: indexPath) as! InvitationCollectionReusableView
            headerView.delegate = self
            if let invitationLink = self.invitationLink {
                headerView.configureLinkView(invitationLink: invitationLink)
            }

            if let invitationRegistered = self.invitationRegistered {
                headerView.configureInvitationRegisteredView(invitationRegisteredResponse: invitationRegistered)
            }

            headerView.configureGiftList(invitationGiftList: self.invitationGiftList)

            return headerView
        }

        return UICollectionReusableView()
    }
}

extension InvitationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.invitationSubscriptionPlanList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let subscriptionPlan = self.invitationSubscriptionPlanList[indexPath.item]
        let cell = collectionView.dequeue(cell: InvitationGiftCollectionViewCell.self, for: indexPath)
        cell.configureCell(subscriptionPlan: subscriptionPlan)
        return cell
    }
}

extension InvitationViewController: InvitationReuseViewDelegate {
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


