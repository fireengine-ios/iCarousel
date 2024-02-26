//
//  DrawCampaignViewController.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit
import AVFoundation

final class DrawCampaignViewController: BaseViewController {
    
    private var containerScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints  = false
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        view.isScrollEnabled = true
        return view
    }()

    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints  = false
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageLabel: PaddingLabel = {
        let view = PaddingLabel()
        view.numberOfLines = 1
        view.layer.backgroundColor = AppColor.background.cgColor
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.highlightColor.color
        view.textAlignment = .center
        view.paddingLeft = 15
        view.paddingRight = 15
        view.paddingTop = 8
        view.paddingBottom = 8
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 16)
        view.textColor = AppColor.highlightColor.color
        view.numberOfLines = 1
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.highlightColor.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = AppColor.borderLightGray.cgColor
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.highlightColor.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var buttonContentView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        view.layer.borderColor = AppColor.borderLightGray.cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    private lazy var drawJoinButton: UIButton = {
        let view = UIButton()
        view.setTitle(localized(.drawJoin), for: .normal)
        view.titleLabel?.font = .appFont(.medium, size: 14)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = AppColor.darkBlueColor.color
        view.layer.cornerRadius = 21
        view.clipsToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = AppColor.darkBlueColor.cgColor
        view.addTarget(self, action: #selector(drawJoinButtonTapped), for: .touchUpInside)
        return view
    }()
   
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    var output: DrawCampaignViewOutput!
    private var campaignStatus: CampaignStatus = .allowed
    private var campaignId: Int = 0
    private var endDate: String = ""
    private var pageTitle: String = ""
    private var responsePolicy: CampaignPolicyResponse?
    private var successJoinDraw: Bool = false
    
    init(campaignId: Int, endDate: String, title: String) {
        self.campaignId = campaignId
        self.endDate = endDate
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: pageTitle)
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        
        showSpinner()
        getCampaignStatus(campaignId: campaignId)
        
    }
    
    private func getCampaignStatus(campaignId: Int) {
        output.getCampaignStatus(campaignId: campaignId)
    }
    
    private func getCampaignPolicy(campaignId: Int) {
        output.getCampaignPolicy(campaignId: campaignId)
    }

    private func setStatus(status: CampaignStatus) {
        campaignStatus = status
        getCampaignPolicy(campaignId: campaignId)
    }
    
    private func setPolicy(response: CampaignPolicyResponse) {
        DispatchQueue.main.async {
            self.responsePolicy = response
            self.setupPage()
            self.labelAtrributed(title: response.title, description: response.description, content: response.content, endDate: self.endDate)
            self.setDrawJoinButton(status: self.campaignStatus)
        }
    }
    
    @objc func drawJoinButtonTapped() {
        if !successJoinDraw {
            switch campaignStatus {
            case .allowed:
                let vc = DrawCampaignNoPackagePopup.with()
                vc.open()
            case .notAllowed:
                showSpinner()
                output.setCampaignApply(campaignId: campaignId)
            case .alreadyParticipated:
                drawJoinButton.isEnabled = false
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func successDrawJoin() {
        labelAtrributed(title: responsePolicy?.title ?? "", description: "Çekiliş başvurunuz tammalanmıştır. Başarılar…", content: "", endDate: self.endDate)
        lineView.isHidden = true
        drawJoinButton.setTitle(TextConstants.ok, for: .normal)
        successJoinDraw = true
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: .discoverCampaignApply)
    }
    
    private func setDrawJoinButton(status: CampaignStatus) {
        switch campaignStatus {
        case .alreadyParticipated:
            drawJoinButton.setTitle(localized(.drawAlreadyJoin), for: .normal)
            drawJoinButton.setTitleColor(.white, for: .normal)
            drawJoinButton.backgroundColor = AppColor.borderLightGray.color
            drawJoinButton.layer.borderWidth = 0.0
            drawJoinButton.layer.borderColor = AppColor.borderLightGray.cgColor
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.image = Image.iconCheckGreen.image
                configuration.imagePlacement = .leading
                configuration.imagePadding = 15.0
                drawJoinButton.configuration = configuration
            }
        default:
            drawJoinButton.setTitle(localized(.drawJoin), for: .normal)
            drawJoinButton.setTitleColor(.white, for: .normal)
            drawJoinButton.backgroundColor = AppColor.darkBlueColor.color
            drawJoinButton.layer.borderWidth = 1.0
            drawJoinButton.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
}

extension DrawCampaignViewController: DrawCampaignViewInput {
    func successCampaignStatus(status: CampaignStatus) {
        setStatus(status: status)
    }
    
    func failCampaignStatus(error: String) {
        hideSpinner()
    }
    
    func successCampaignPolicy(response: CampaignPolicyResponse) {
        hideSpinner()
        setPolicy(response: response)
    }
    
    func failCampaignPolicy(error: String) {
        hideSpinner()
    }
    
    func successCampaignApply() {
        hideSpinner()
        successDrawJoin()
    }
}

extension DrawCampaignViewController {
    private func setupPage() {
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(contentView)
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        containerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        containerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        containerScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        
        containerScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: containerScrollView.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerScrollView.leadingAnchor, constant: 0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerScrollView.trailingAnchor, constant: 0).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor, constant: 20).isActive = true
        contentView.widthAnchor.constraint(equalTo: containerScrollView.widthAnchor, constant: 0).isActive = true
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        
        imageView.addSubview(imageLabel)
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10).isActive = true
        imageLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10).isActive = true
        imageLabel.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        
        contentView.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10).isActive = true
        lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        contentView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 20).isActive = true
        contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120).isActive = true
        
        view.addSubview(buttonContentView)
        buttonContentView.translatesAutoresizingMaskIntoConstraints = false
        buttonContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        buttonContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        buttonContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        buttonContentView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        buttonContentView.addSubview(drawJoinButton)
        drawJoinButton.translatesAutoresizingMaskIntoConstraints = false
        drawJoinButton.topAnchor.constraint(equalTo: buttonContentView.topAnchor, constant: 20).isActive = true
        drawJoinButton.leadingAnchor.constraint(equalTo: buttonContentView.leadingAnchor, constant: 60).isActive = true
        drawJoinButton.trailingAnchor.constraint(equalTo: buttonContentView.trailingAnchor, constant: -60).isActive = true
        drawJoinButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        
        
    }
}

extension DrawCampaignViewController {
    private func labelAtrributed(title: String, description: String, content: String, endDate: String) {
        let descriptionText = "lifebox’tan paket satın alan 50 kişiyle Milli Takım antrenmanına katılma şansını yakala"
        let contentText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
        
        titleLabel.text = title
        
        imageLabel.text = "\(localized(.drawEnddate)) \(endDate)"
        
        let descriptionString = NSMutableAttributedString(string: description)
        let descriptionParagraphStyle = NSMutableParagraphStyle()
        descriptionParagraphStyle.lineSpacing = 3
        descriptionString.addAttribute(NSAttributedString.Key.paragraphStyle, value:descriptionParagraphStyle, range:NSMakeRange(0, descriptionString.length))
        descriptionLabel.attributedText = descriptionString
        
        let contentString = NSMutableAttributedString(string: content)
        let contentParagraphStyle = NSMutableParagraphStyle()
        contentParagraphStyle.lineSpacing = 3
        contentString.addAttribute(NSAttributedString.Key.paragraphStyle, value:contentParagraphStyle, range:NSMakeRange(0, contentString.length))
        contentLabel.attributedText = contentString
    }
}
