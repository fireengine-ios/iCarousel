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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topArrowImage: UIImageView!
    @IBOutlet weak var bottomArrowImage: UIImageView!
    
    private var spotlightRect: CGRect = .zero {
        didSet {
            topConstraint.constant = spotlightRect.minY
            leftContraint.constant = spotlightRect.minX - 20
            heightConstraint.constant = spotlightRect.height + 30
            widthConstaint.constant = spotlightRect.width + 40
            view.layoutIfNeeded()
        }
    }
    private var message: String = ""
    
    private var oldStatusBarColor: UIColor?
    
    private let backgroundColor = UIColor(white: 0, alpha: 0.8)
    
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
