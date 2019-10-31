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
    
    @IBOutlet private weak var analyzeButtonShadowView: UIView! {
        willSet {
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = analyzeButton.layer.cornerRadius
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = CGSize(width: 0, height: 3)
            newValue.layer.shadowPath = UIBezierPath(roundedRect: newValue.bounds, cornerRadius: analyzeButton.layer.cornerRadius).cgPath
        }
    }
    
    @IBOutlet private weak var analyzeView: UIView! {
        willSet {
            let gradientView = TransparentGradientView(style: .vertical, mainColor: .white)
            gradientView.frame = newValue.bounds
            newValue.addSubview(gradientView)
            newValue.sendSubview(toBack: gradientView)
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    private var moreInfoUrl: URL?
    private let service = CampaignServiceImpl()
    private lazy var router = RouterVC()
    
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
        
        service.getPhotopickDetails { [weak self] result in
            guard let self = self else {
                return
            }

            self.hideSpinner()
            
            switch result {
            case .success(let details):
                self.updateUI(details: details)
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
        contentStackView.isHidden = true
        analyzeView.isHidden = true
    }
    
    private func updateUI(details: CampaignCardResponse) {
        if details.startDate.timeIntervalSinceNow < 0 && details.endDate.timeIntervalSinceNow > 0 {
            analyzeView.isHidden = false
            campaignIntroView.isHidden = false
            campaignInfoView.isHidden = true
            scrollView.contentInset.bottom = analyzeView.frame.height
        } else {
            campaignIntroView.isHidden = true
            campaignInfoView.isHidden = false
            analyzeView.isHidden = true
            scrollView.contentInset = .zero
        }
        
        imageView.loadImage(url: details.imageUrl)
        contestInfoView.setup(with: details)
        
        moreInfoUrl = details.detailsUrl
        let buttonText = String(format: TextConstants.campaignDetailMoreInfoButton, moreInfoUrl!.absoluteString)
        moreInfoButton.setTitle(buttonText, for: .normal)
        
        contentStackView.isHidden = false
    }
    
    
    // MARK: - Actions
    
    @IBAction private func onMoreTapped(_ sender: UIButton) {
        UIApplication.shared.openSafely(moreInfoUrl)
    }
    
    @IBAction private func onAnalyzeTapped(_ sender: UIButton) {
        let controller = router.analyzesHistoryController()
        router.pushViewController(viewController: controller)
    }

}
