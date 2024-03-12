//
//  NavigationHeaderButton.swift
//  Depo
//
//  Created by Hady on 4/20/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class NavigationHeaderButton: UIButton {
    
    private lazy var notificationLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.bold, size: 12)
        view.textColor = .white
        return view
    }()
    
    private lazy var loadingBadgeView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = Image.iconHeaderPreparing.image
        return view
    }()
    
    private lazy var loadingImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = Image.loadingCircle.image
        return view
    }()
    
    private let singletonStorage = SingletonStorage.shared
    private let userDefaultsVars = UserDefaultsVars()
    private var topConstant: CGFloat = -2.0
    private var trailingConstant: CGFloat = 0.0
    private var heightWidthAnchor: CGFloat = 16.0
    private var topConstantForLoading: CGFloat = 4
    private var trailingConstantForLoading: CGFloat = -5
    private var heightWidthAnchorForLoading: CGFloat = 32
    private var timer: Timer?
    private lazy var earingView = UIView()
    private var notificationCount: Int = 0
    
    convenience init(type: `Type`, target: Any? = nil, action: Selector? = nil) {
        self.init()
        loadingImageView.isHidden = true
        setImage(type.image?.image, for: .normal)
        setProfilePhotos(type: type)
        accessibilityIdentifier = type.accessibilityId
        accessibilityLabel = type.accessibilityLabel
        if let target = target, let action = action {
            addTarget(target, action: action, for: .primaryActionTriggered)
        }
        
        if type == .settings {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(stopLoadingAndStartNotification),
                                                   name: .isProcecessPrepairing,
                                                   object: nil)
            if userDefaultsVars.isProcessPrepairingDone ?? true {
                addNotification()
            } else {
                addLoadingView()
            }
        }
    }
    
    @objc func stopLoadingAndStartNotification() {
        DispatchQueue.main.async {
            self.stopTimer()
            self.addNotification()
            self.setnotificationCount(with: self.notificationCount)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 42, height: 42)
    }
    
    private func setProfilePhotos(type: `Type`) {
        if type == .settings {
            if singletonStorage.isSetProfilePhotoImage {
                setImage(singletonStorage.profilePhotoImage.image, for: .normal)
                imageView?.layer.borderWidth = 1
                imageView?.layer.cornerRadius = 21
                imageView?.layer.borderColor = UIColor.black.cgColor
                imageView?.contentMode = .scaleAspectFill
            }
        }
    }
    
    private func addLoadingView() {
        if singletonStorage.isSetProfilePhotoImage {
            topConstant = -6
            trailingConstant = 6
            heightWidthAnchor = 20
            topConstantForLoading = 0
            trailingConstantForLoading = 0
            heightWidthAnchorForLoading = 42
        }
        
        addSubview(loadingImageView)
        loadingImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingImageView.topAnchor.constraint(equalTo: topAnchor, constant: topConstantForLoading).activate()
        loadingImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstantForLoading).activate()
        loadingImageView.heightAnchor.constraint(equalToConstant: heightWidthAnchorForLoading).activate()
        loadingImageView.widthAnchor.constraint(equalToConstant: heightWidthAnchorForLoading).activate()
        self.bringSubviewToFront(loadingImageView)
        
        addSubview(loadingBadgeView)
        loadingBadgeView.translatesAutoresizingMaskIntoConstraints = false
        loadingBadgeView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).activate()
        loadingBadgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant).activate()
        loadingBadgeView.heightAnchor.constraint(equalToConstant: heightWidthAnchor).activate()
        loadingBadgeView.widthAnchor.constraint(equalToConstant: heightWidthAnchor).activate()
        loadingImageView.bringSubviewToFront(loadingBadgeView)
        
        startTimer()
    }
}

extension NavigationHeaderButton {
    private func addNotification() {
        if singletonStorage.isSetProfilePhotoImage {
            topConstant = -6
            trailingConstant = 6
            heightWidthAnchor = 20
        }
        
        earingView.isHidden = true
        earingView.backgroundColor = AppColor.notification.color
        earingView.layer.cornerRadius = heightWidthAnchor / 2
        
        earingView.addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.centerYAnchor.constraint(equalTo: earingView.centerYAnchor).activate()
        notificationLabel.centerXAnchor.constraint(equalTo: earingView.centerXAnchor).activate()
        
        addSubview(earingView)
        earingView.translatesAutoresizingMaskIntoConstraints = false
        earingView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant).activate()
        earingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingConstant).activate()
        earingView.heightAnchor.constraint(equalToConstant: heightWidthAnchor).activate()
        earingView.widthAnchor.constraint(equalToConstant: heightWidthAnchor).activate()
    }
    
    func setnotificationCount(with number: Int) {
        notificationCount = number
        notificationLabel.superview?.isHidden = number == 0 ? true : false
        
        let strNum = String(number)
        notificationLabel.text = number > 9 ? "9+" : strNum
    }
    
    enum `Type` {
        case settings
        case search
        case plus

        var image: NavigationBarImage? {
            switch self {
            case .settings:
                return .headerActionSettings
            case .search:
                return .headerActionSearch
            case .plus:
                return .headerActionPlus
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .settings:
                return TextConstants.settings
            case .search:
                return TextConstants.search
            case .plus:
                return TextConstants.accessibilityPlus
            }
        }

        var accessibilityId: String {
            switch self {
            case .settings:
                return "NavigationHeaderButtonSettings"
            case .search:
                return "NavigationHeaderButtonSearch"
            case .plus:
                return "NavigationHeaderButtonPlus"
            }
        }
    }
}


extension NavigationHeaderButton {
    func startTimer() {
        loadingImageView.isHidden = false
        loadingBadgeView.isHidden = false
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval:0.0, target: self, selector: #selector(self.animateView), userInfo: nil, repeats: false)
        }
    }
    
    @objc func animateView() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveLinear, animations: {
            self.loadingImageView.transform = self.loadingImageView.transform.rotated(by: CGFloat(Double.pi))
        }, completion: { (finished) in
            if self.timer != nil {
                self.timer = Timer.scheduledTimer(timeInterval:0.0, target: self, selector: #selector(self.animateView), userInfo: nil, repeats: false)
            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        loadingImageView.isHidden = true
        loadingBadgeView.isHidden = true
    }
}
