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
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var contestInfoView: CampaignContestInfoView!
    @IBOutlet private weak var campaignIntroView: CampaignIntroView!
    @IBOutlet private weak var campaignInfoView: CampaingnInfoView!
    @IBOutlet private weak var moreInfoButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.campaignDetailMoreInfoButton, for: .normal)
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

    private let moreInfoUrl = URL(string: "https://www.turkcell.com.tr")
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = TextConstants.campaignDetailTitle
        imageView.backgroundColor = .black
        
        scrollView.contentInset.bottom = analyzeView.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func loadDetailsInfo() {
        showSpinner()
        
        
    }
    
    private func updateUI() {
        if true {
            analyzeView.isHidden = true
            campaignIntroView.isHidden = false
            campaignInfoView.isHidden = true
            scrollView.contentInset = .zero
        } else {
            campaignIntroView.isHidden = true
            campaignInfoView.isHidden = false
            analyzeView.isHidden = false
            scrollView.contentInset.bottom = analyzeView.frame.height
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction private func onMoreTapped(_ sender: UIButton) {
        UIApplication.shared.openSafely(moreInfoUrl)
    }
    
    @IBAction private func onAnalyzeTapped(_ sender: UIButton) {
        
    }

}
