//
//  SpotlightController.swift
//  Depo
//
//  Created by Andrei Novikau on 19/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class SpotlightViewController: ViewController {

    @IBOutlet weak var spotlightImageView: UIImageView!
    @IBOutlet weak var leftContraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstaint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet var backgroundViews: [UIView]!
    
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var topArrowImage: UIImageView!
    @IBOutlet weak var bottomTitleLabel: UILabel!
    @IBOutlet weak var bottomArrowImage: UIImageView!
    
    private let topOffset: CGFloat = Device.operationSystemVersionLessThen(11) ? 0 : UIApplication.shared.statusBarFrame.height
    private let borderOffset: CGFloat = 20
    
    private var spotlightRect: CGRect = .zero {
        didSet {
            topConstraint.constant = spotlightRect.minY - borderOffset + topOffset
            leftContraint.constant = spotlightRect.minX - borderOffset
            heightConstraint.constant = spotlightRect.height + borderOffset * 2
            widthConstaint.constant = spotlightRect.width + borderOffset * 2
            view.layoutIfNeeded()
        }
    }
    private var message: String = ""
    
    private var oldStatusBarColor: UIColor?
    
    private let backgroundColor = UIColor(white: 0, alpha: 0.8)
    
    private var dismissHandler: VoidHandler?
    
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
        modalTransitionStyle = .crossDissolve
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)));
        view.addGestureRecognizer(gesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI()
        oldStatusBarColor = statusBarColor
        statusBarColor = .clear
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let oldStatusBarColor = oldStatusBarColor {
            statusBarColor = oldStatusBarColor
        }
    }
    
    private func configureUI() {
        backgroundViews.forEach { view in
            view.backgroundColor = backgroundColor
        }
        
        let bottom = Device.winSize.height - heightConstraint.constant - topConstraint.constant
        
        if topConstraint.constant >= bottom {
            topTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            topTitleLabel.text = message
            topArrowImage.isHidden = false
            bottomTitleLabel.text = ""
            bottomArrowImage.isHidden = true
        } else {
            topTitleLabel.text = ""
            topArrowImage.isHidden = true
            bottomTitleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            bottomTitleLabel.text = message
            bottomArrowImage.isHidden = false
        }
    }
}

extension SpotlightViewController: NibInit {

    static func with(rect: CGRect, message: String, completion: VoidHandler? = nil) -> SpotlightViewController {
        let controller = SpotlightViewController.initFromNib()
        controller.spotlightRect = rect
        controller.message = message
        controller.dismissHandler = completion
        return controller
    }
}

extension SpotlightViewController {
    @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
        dismiss(animated: true, completion: dismissHandler)
    }
}
