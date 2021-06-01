//
//  InvitationCampaignDetailView.swift
//  Depo
//
//  Created by Alper Kırdök on 17.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class InvitationCampaignDetailView: UIView, NibInit {

    @IBOutlet weak var campaignDetailImageView: LoadingImageView!
    @IBOutlet weak var campaignDetailTextView: UITextView!
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
        self.showSpinner()
        InvitationApiService().getInvitationCampaign { result in
            self.hideSpinner()
            switch result {
            case .success(let response):
                self.setupViewWithObject(campaign: response)
            case .failed(let error):
                print("invitation campaign response error = \(error.description)")
            }
        }
    }

    private func setupViewWithObject(campaign: InvitationCampaignResponse) {
        campaignDetailImageView.setLogs(enabled: true)
        let imageUrl = URL(string: campaign.value.image)
        campaignDetailImageView.loadImageData(with: imageUrl)
        self.campaignDetailTextView.text = campaign.value.content
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        removeFromSuperview()
    }
}
