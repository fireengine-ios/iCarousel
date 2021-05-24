//
//  InvitationCollectionReusableView.swift
//  Depo
//
//  Created by Alper Kırdök on 5.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol InvitationReuseViewDelegate {
    func invitationListButtonTapped()
    func invitationCampaignDetail()
    func invitationShareLink(shareButton: UIButton)
}

class InvitationCollectionReusableView: UICollectionReusableView {

    static let reuseId = "InvitationCollectionReusableView"
    var delegate: InvitationReuseViewDelegate?

    @IBOutlet weak var campaignDetailLabel: UILabel!

    @IBOutlet weak var invitationLinkTitleLabel: UILabel!
    @IBOutlet weak var invitationLinkLabel: UILabel!
    @IBOutlet weak var invitationLinkShareButton: UIButton!
    @IBOutlet weak var copyLinkBGView: UIView!

    @IBOutlet weak var acceptedInvitationTitleLabel: UILabel!
    @IBOutlet weak var acceptedInvitationListCollectionView: UICollectionView!

    @IBOutlet weak var giftsTitleLabel: UILabel!

    private var invitationRegisteredResponse: InvitationRegisteredResponse?
    private var acceptedCollectionViewNumberOfItem = 0
    private var accountBGColors = [UIColor]()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
        setupLocalizable()
        registerCells()
    }

    private func setupView() {
        copyLinkBGView.layer.borderWidth = 1
        copyLinkBGView.layer.borderColor = ColorConstants.darkBlueColor.cgColor

        acceptedInvitationListCollectionView.delegate = self
        acceptedInvitationListCollectionView.dataSource = self
    }

    private func setupLocalizable() {
        campaignDetailLabel.text = TextConstants.titleInvitationCampaign
        invitationLinkTitleLabel.text = TextConstants.titleInvitationLink
        invitationLinkShareButton.setTitle(TextConstants.invitationShare, for: .normal)
    }

    private func registerCells() {
        acceptedInvitationListCollectionView.register(nibCell: InvitedPeopleCollectionViewCell.self)
    }

    func configureLinkView(invitationLink: InvitationLink) {
        invitationLinkLabel.text = invitationLink.value
    }

    func configureInvitationRegisteredView(invitationRegisteredResponse: InvitationRegisteredResponse) {
        self.invitationRegisteredResponse = invitationRegisteredResponse
        calculateNumberOfItems(invitationRegisteredResponse: invitationRegisteredResponse)
        self.accountBGColors = AccountConstants.shared.generateBGColors(numberOfItems: maxShownNumberOfItem)
        acceptedInvitationTitleLabel.text = String(format: TextConstants.titleInvitationFriends, self.invitationRegisteredResponse?.totalAccount ?? 0)
        acceptedInvitationListCollectionView.reloadData()
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

    @IBAction func campaignDetailButtonTapped(_ sender: Any) {
        self.delegate?.invitationCampaignDetail()
    }

    @IBAction func invitationLinkShareButtonTapped(_ sender: Any) {
        self.delegate?.invitationShareLink(shareButton: invitationLinkShareButton)
    }

    @IBAction func invitationLinkCopyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = invitationLinkLabel.text

        let message = TextConstants.invitationSnackbarCopy
        SnackbarManager.shared.show(type: SnackbarType.action, message: message)
    }

    @IBAction func invitationListButtonTapped(_ sender: Any) {
        self.delegate?.invitationListButtonTapped()
    }
}

extension InvitationCollectionReusableView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 71)
    }
}

extension InvitationCollectionReusableView: UICollectionViewDataSource {
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
