//
//  CampaignDetailViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 10/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CampaignDetailViewController: BaseViewController, NibInit {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var imageView: LoadingImageView!
    @IBOutlet private weak var contestInfoView: CampaignContestInfoView!
    @IBOutlet private weak var campaignIntroView: CampaignIntroView!
    @IBOutlet private weak var campaignInfoView: CampaingnInfoView!
    @IBOutlet private weak var moreInfoButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.titleLabel?.numberOfLines = 2
            newValue.titleLabel?.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet private weak var analyzeButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.analyzeHistoryAnalyseButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var analyzeView: UIView! {
        willSet {
            let gradientView = TransparentGradientView(style: .vertical, mainColor: .white)
            gradientView.frame = newValue.bounds
            newValue.addSubview(gradientView)
            newValue.sendSubview(toBack: gradientView)
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let buttonShadowView = UIView(frame: analyzeButton.frame)
            buttonShadowView.layer.masksToBounds = false
            buttonShadowView.layer.cornerRadius = analyzeButton.layer.cornerRadius
            buttonShadowView.layer.shadowOpacity = 0.5
            buttonShadowView.layer.shadowColor = UIColor.black.cgColor
            buttonShadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
            buttonShadowView.layer.shadowPath = UIBezierPath(roundedRect: buttonShadowView.bounds, cornerRadius: analyzeButton.layer.cornerRadius).cgPath
            newValue.insertSubview(buttonShadowView, belowSubview: analyzeButton)
        }
    }

    private var moreInfoUrl: URL?
    private let service = CampaignServiceImpl()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadDetailsInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func loadDetailsInfo() {
        showSpinner()
        
        service.getPhotopickStatus { [weak self] result in
            guard let self = self else {
                return
            }

            self.hideSpinner()
            
            switch result {
            case .success(let status):
                self.updateUI(status: status)
            case .failure(let errorResult):
                switch errorResult {
                case .empty:
                    break
                case .error(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
        }
    }
    
    private func setupUI() {
        navigationItem.title = TextConstants.campaignDetailTitle
        imageView.backgroundColor = .black
        contentStackView.isHidden = true
        analyzeView.isHidden = true
    }
    
    private func updateUI(status: CampaignPhotopickStatus) {
        if status.dates.startDate.timeIntervalSinceNow > 0 && status.dates.endDate.timeIntervalSinceNow < 0 {
            analyzeView.isHidden = true
            campaignIntroView.isHidden = false
            campaignInfoView.isHidden = true
            scrollView.contentInset = .zero
            campaignIntroView.setup(with: status)
        } else {
            campaignIntroView.isHidden = true
            campaignInfoView.isHidden = false
            analyzeView.isHidden = false
            scrollView.contentInset.bottom = analyzeView.frame.height
            campaignInfoView.setup(with: status.content)
        }
        
        imageView.loadImage(url: status.imageUrl)
        contestInfoView.setup(with: status.usage)
        
        moreInfoUrl = status.detailsUrl
        let buttonText = String(format: TextConstants.campaignDetailMoreInfoButton, moreInfoUrl!.absoluteString)
        moreInfoButton.setTitle(buttonText, for: .normal)
        
        contentStackView.isHidden = false
    }
    
    
    // MARK: - Actions
    
    @IBAction private func onMoreTapped(_ sender: UIButton) {
        UIApplication.shared.openSafely(moreInfoUrl)
    }
    
    @IBAction private func onAnalyzeTapped(_ sender: UIButton) {
        
    }

}
