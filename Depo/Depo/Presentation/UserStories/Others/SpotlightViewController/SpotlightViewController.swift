//
//  SpotlightController.swift
//  Depo
//
//  Created by Andrei Novikau on 19/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class SpotlightViewController: BaseViewController {

    @IBOutlet weak var spotlightImageView: UIImageView!
    @IBOutlet weak var leftContraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstaint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var backgroundViews: [UIView]!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topArrowImage: UIImageView!
    @IBOutlet weak var bottomArrowImage: UIImageView!
    
    private lazy var transitionController: SpotlightTransitionController = {
        let controller = SpotlightTransitionController()
        controller.delegate = self
        return controller
    }()
    
    private var spotlightRect: CGRect = .zero {
        didSet {
            topConstraint.constant = spotlightRect.minY - 15
            leftContraint.constant = spotlightRect.minX - 20
            heightConstraint.constant = spotlightRect.height + 30
            widthConstaint.constant = spotlightRect.width + 30
            view.layoutIfNeeded()
        }
    }
    private var message: String = ""
    
    private var oldStatusBarColor: UIColor?
    
    private let backgroundColor = UIColor(white: 0, alpha: 0.85)
    
    //MARK: - Initialization
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)));
        view.addGestureRecognizer(gesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
    }
    
    private func configureUI() {
        backgroundViews.forEach { view in
            view.backgroundColor = backgroundColor
        }
        
        
    }
    
}

extension SpotlightViewController: NibInit {

    static func with(rect: CGRect, message: String) -> SpotlightViewController {
        let controller = SpotlightViewController.initFromNib()
        controller.spotlightRect = rect
        controller.message = message
        return controller
    }
}

extension SpotlightViewController {
    @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension SpotlightViewController: SpotlightTransitionControllerDelegate {
    func spotlightTransitionWillPresent(_ controller: SpotlightTransitionController, transitionContext: UIViewControllerContextTransitioning) {
        oldStatusBarColor = statusBarColor
        statusBarColor = .clear
    }
    
    func spotlightTransitionWillDismiss(_ controller: SpotlightTransitionController, transitionContext: UIViewControllerContextTransitioning) {
        if let oldStatusBarColor = oldStatusBarColor {
            statusBarColor = oldStatusBarColor
        }
    }
}

extension SpotlightViewController {
    override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionController.isPresent = true
        return transitionController
    }

    override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionController.isPresent = false
        return transitionController
    }
}
