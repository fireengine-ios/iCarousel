//
//  InstaPickCampaignViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/22/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum InstaPickCampaignViewControllerMode {
    case withLeftPhotoPick
    case withoutLeftPhotoPick
}

final class InstaPickCampaignViewController: UIViewController, NibInit {
    
    @IBOutlet private var instaPickViewControllerDesigner: InstaPickCampaignViewControllerDesigner!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    //MARK: TopView
    @IBOutlet private weak var topViewBackgroundImage: LoadingImageView!
    @IBOutlet private weak var premiumButtonView: UIView!
    @IBOutlet private weak var topViewTitileLabel: UILabel!
    @IBOutlet private weak var topViewDescriptionLabel: UILabel!
    
    
    //MARK: Bottom view
    @IBOutlet private weak var bottomViewImage: LoadingImageView!
    @IBOutlet weak var bottomViewTitleLabel: UILabel!
    @IBOutlet weak var bottomViewDescriptionLabel: UILabel!
    
    private var showAnimatedAgain = true
    
    private var controllerMode: InstaPickCampaignViewControllerMode?
    private var controllerContent: CampaignCardResponse?
    private lazy var router = RouterVC()
    var didClosed: VoidHandler?
    
    static func createController(controllerMode: InstaPickCampaignViewControllerMode, with data: CampaignCardResponse) -> InstaPickCampaignViewController {
        let controller = InstaPickCampaignViewController()
        controller.controllerMode = controllerMode
        controller.controllerContent = data
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mode: controllerMode, data: controllerContent)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if showAnimatedAgain {
            open()
        }
    }
    
    private func setupView(mode: InstaPickCampaignViewControllerMode?, data: CampaignCardResponse?) {
        
        guard let mode = controllerMode, let content = controllerContent else {
            assertionFailure()
            return
        }
        
        switch mode {
        case .withLeftPhotoPick:
            premiumButtonView.isHidden = true
            topViewBackgroundImage.image = UIImage(named: "campaignBackgroundImage")
            setupTopView(dailyRemaining: content.dailyRemaining, totalsUsed: content.totalUsed)
        case .withoutLeftPhotoPick:
            topViewTitileLabel.text = TextConstants.campaignTopViewTitleWithoutPhotoPick
            topViewDescriptionLabel.text = TextConstants.campaignTopViewDescriptionWithoutPhotoPick
            topViewBackgroundImage.image = UIImage(named: "camapaignPremiumBackground")
        }
        
        bottomViewTitleLabel.text = TextConstants.campaignViewControllerBottomViewTitle
        bottomViewDescriptionLabel.text = TextConstants.campaignViewControllerBottomViewDescription
        bottomViewImage.loadImage(url: content.imageUrl)
    }
    
    private func setupTopView(dailyRemaining: Int, totalsUsed: Int) {
        switch dailyRemaining {
        case 0:
            topViewTitileLabel.text = TextConstants.campaignTopViewTitleZeroRemainin
            topViewDescriptionLabel.text = TextConstants.campaignTopViewDescriptionZeroRemaining
        case 1...:
            topViewTitileLabel.text = TextConstants.campaignTopViewTitleRemainin
            topViewDescriptionLabel.text = String(format: TextConstants.campaignTopViewDescriptionRemainin, totalsUsed)
        default:
            assertionFailure()
        }
    }
    
    private func open() {
        showAnimatedAgain = false
        scrollView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.scrollView.transform = .identity
        }
    }
    
    private func close(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.scrollView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    func closeAfterBecomPremium() {
        close(completion: didClosed)
    }
    
    @IBAction private  func editProfileButtonTapped(_ sender: Any) {
        
        guard let userInfo = SingletonStorage.shared.accountInfo  else {
            assertionFailure()
            return
        }
        
        let isTurkcell = SingletonStorage.shared.isTurkcellUser
        let controller = router.userProfile(userInfo: userInfo, isTurkcellUser: isTurkcell)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func becomePremiumButtonTapped(_ sender: Any) {
        let controller = router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember, viewControllerForPresentOn: self)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func showResultButtonTapped(_ sender: Any) {
        close(completion: didClosed)
    }
}
