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
    @IBOutlet private weak var imageViewHeightConstaint: NSLayoutConstraint!
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
    private var cellImageManager: CellImageManager?
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private let instaPickService: InstapickService = factory.resolve()
    
    // MARK: - View lifecycle
    
    deinit {
        instaPickService.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadDetailsInfo(needShowSpinner: true)
        instaPickService.delegates.add(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImageConstraint()
    }
    
    private func loadDetailsInfo(needShowSpinner: Bool) {
        if needShowSpinner {
            showSpinner()
        }
        
        service.getPhotopickDetails { [weak self] result in
            guard let self = self else {
                return
            }

            if needShowSpinner {
                self.hideSpinner()
            }
            
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
        if (details.startDate...details.endDate).contains(Date()) {
            analyzeView.isHidden = false
            campaignIntroView.isHidden = false
            campaignInfoView.isHidden = true
            scrollView.contentInset.bottom = analyzeView.frame.height
            
            trackScreen(.campaignDetailDuring)
        } else {
            campaignIntroView.isHidden = true
            campaignInfoView.isHidden = false
            analyzeView.isHidden = true
            scrollView.contentInset = .zero
            
            trackScreen(.campaignDetailAfter)
        }
        
        loadImage(with: details.imageUrl)
        contestInfoView.setup(with: details)
        
        moreInfoUrl = URL(string: details.detailsUrl)
        moreInfoButton.setTitle(TextConstants.campaignDetailMoreInfoButton, for: .normal)
        
        contentStackView.isHidden = false
    }
    
    private func trackScreen(_ screen: AnalyticsAppScreens) {
        analyticsService.logScreen(screen: screen)
        analyticsService.trackDimentionsEveryClickGA(screen: screen)
    }
    
    private func loadImage(with url: URL?) {
        guard let url = url else {
            return
        }
        
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
                self.updateImageConstraint()
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
    }

    private func updateImageConstraint() {
        let height: CGFloat
        if let image = imageView.image {
            height = min(view.bounds.height * 0.5, image.size.height / image.size.width * imageView.bounds.width)
        } else {
            // 133/344 - aspect from design
            height = imageView.bounds.width * 133/344
        }
        imageViewHeightConstaint.constant = height
        view.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @IBAction private func onMoreTapped(_ sender: UIButton) {
        guard let urlString = moreInfoUrl?.absoluteString else {
            return
        }
        
        let controller = WebViewController(urlString: urlString)
        router.pushViewController(viewController: controller)
    }
    
    @IBAction private func onAnalyzeTapped(_ sender: UIButton) {
        let controller = router.analyzesHistoryController()
        router.pushViewController(viewController: controller)
    }

}

// MARK: - InstaPickServiceDelegate

extension CampaignDetailViewController: InstaPickServiceDelegate {
    
    func didRemoveAnalysis() {}
    
    func didFinishAnalysis(_ analyses: [InstapickAnalyze]) {
        loadDetailsInfo(needShowSpinner: false)
    }
}
