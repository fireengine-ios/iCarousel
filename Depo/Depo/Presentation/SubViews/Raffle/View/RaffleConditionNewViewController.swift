//
//  RaffleConditionNewViewController.swift
//  Depo
//
//  Created by Ozan Salman on 20.05.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation
import SDWebImage

final class RaffleConditionNewViewController: BaseViewController {
    
    private lazy var containerScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColor.background.color
        view.isScrollEnabled = true
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColor.background.color
        return view
    }()
    
    private lazy var topTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = AppColor.settingsButtonColor.cgColor
        return view
    }()
    
    private lazy var topImageView: LoadingImageView = {
        let view = LoadingImageView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var bottomTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = AppColor.lightGrayColor.cgColor
        return view
    }()
    
    private lazy var bottomTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = AppColor.background.color
        view.textColor = AppColor.label.color
        view.font = .appFont(.medium, size: 8)
        view.textAlignment = .left
        return view
    }()
    
    private var statusResponse: RaffleStatusResponse?
    private var raffleStatusElement: [RaffleElement] = []
    private var raffleStatusElementOppacity: [Float] = []
    private var rulesText: String = ""
    private var campaignId: Int = 0
    private var imageSize = CGSize()
    private var conditionImageUrl: String = ""
    
    init(statusResponse: RaffleStatusResponse?, conditionImageUrl: String, campaignId: Int) {
        self.statusResponse = statusResponse
        self.conditionImageUrl = conditionImageUrl
        self.campaignId = campaignId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: localized(.gamificationCampaignConditions))
        view.backgroundColor = AppColor.background.color
        showSpinner()
        getRaffleRules()
    }
    
    private func getRaffleRules() {
        let service = RaffleService()
        service.getRaffleConditions(id: campaignId) { [weak self] result in
            switch result {
            case .success(let stringResponse):
                self?.hideSpinner()
                self?.rulesText = stringResponse
                self?.topImageView.sd_setImage(with: URL(string: self?.conditionImageUrl ?? ""), completed: { image, _, _, _ in
                    self?.imageSize = image?.size ?? CGSize(width: 0, height: 0)
                    self?.setupPage()
                })
            case .failed(let error):
                self?.hideSpinner()
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
}

extension RaffleConditionNewViewController {
    private func setupPage() {
        view.addSubview(containerScrollView)
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        
        containerScrollView.addSubview(contentView)
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: containerScrollView.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: 20).isActive = true
        contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor, constant: 0).isActive = true
        
        contentView.addSubview(topTitleLabel)
        topTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        topTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        topTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        topTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contentView.addSubview(topLineView)
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        topLineView.topAnchor.constraint(equalTo: topTitleLabel.bottomAnchor, constant: 8).isActive = true
        topLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        topLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        topLineView.heightAnchor.constraint(equalToConstant: 1).activate()
        
        let ratio = (view.frame.width - 40) / imageSize.width
        let imageViewHeight = imageSize.height / ratio
        
        contentView.addSubview(topImageView)
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.topAnchor.constraint(equalTo: topLineView.bottomAnchor, constant: 8).isActive = true
        topImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        topImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        topImageView.heightAnchor.constraint(equalToConstant: imageViewHeight).activate()
        
        contentView.addSubview(bottomTitleLabel)
        bottomTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomTitleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 16).isActive = true
        bottomTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        bottomTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        contentView.addSubview(bottomLineView)
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomLineView.topAnchor.constraint(equalTo: bottomTitleLabel.bottomAnchor, constant: 8).isActive = true
        bottomLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        bottomLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        bottomLineView.heightAnchor.constraint(equalToConstant: 1).activate()
        
        contentView.addSubview(bottomTextView)
        bottomTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomTextView.topAnchor.constraint(equalTo: bottomLineView.bottomAnchor, constant: 20).activate()
        bottomTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).activate()
        bottomTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).activate()
        bottomTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).activate()
        bottomTextView.heightAnchor.constraint(equalToConstant: 600).activate()

        
        
        topTitleLabel.text = localized(.gamificationRules)
        bottomTitleLabel.text = localized(.gamificationCampaignPolicyTitle)
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                bottomTextView.attributedText = rulesText.getAsHtml
            } else {
                bottomTextView.attributedText = rulesText.getAsHtmldarkMode
            }
        } else {
            bottomTextView.attributedText = rulesText.getAsHtml
        }
    }
}

