//
//  NotificationTableViewCell.swift
//  Depo
//
//  Created by yilmaz edis on 10.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftUI

class NotificationTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 16)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.regular, size: 12)
        view.textColor = AppColor.billoGrayAndWhite.color
        view.textAlignment = .left
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var cardImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = Image.iconFilePhotoBig.image
        view.layer.cornerRadius = 6
        
        return view
    }()
    
    private lazy var checkBox: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        return view
    }()
    
    private lazy var warningImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = Image.iconErrorRed.image
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        view.layer.borderColor = AppColor.tint.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private lazy var underContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = AppColor.discoverCardLine.color
        view.layer.borderColor = AppColor.discoverCardLine.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private lazy var deleteImageView: UIImageView = {
        let view = UIImageView()
        view.image = Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        return view
    }()
    
    private var warningCase = false
    private var canSwipe = true
    var deleteHandler: (() -> Void)?
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
        setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer.isKind(of: UIPanGestureRecognizer.self)) {
            let t = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: contentView)
            let verticalness = abs(t.y)
            if (verticalness > 0) {
                print("ignore vertical motion in the pan ...")
                print("the event engine will >pass on the gesture< to the scroll view")
                return false
            }
        }
        return true
    }
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        /// Cause, I dont want to swipe cell while in select mode
        guard canSwipe else { return }
        
        let translation = gestureRecognizer.translation(in: containerView)
    
        switch gestureRecognizer.state {
        case .changed:
            // Prevent it from sliding to the right
            guard translation.x < 0 else { return }
            
            containerView.transform = CGAffineTransform(translationX: translation.x , y: 0)
        case .ended:
            if translation.x < -containerView.bounds.size.width / 2 {
                deleteHandler?()
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = .identity
                }
            }
        default:
            break
        }
    }
    
    private func setLayout() {
        /// underContainerView Layout
        addSubview(underContainerView)
        underContainerView.translatesAutoresizingMaskIntoConstraints = false
        underContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 6).activate()
        underContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).activate()
        underContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).activate()
        underContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).activate()
        underContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 76).activate()
        
        underContainerView.addSubview(deleteImageView)
        deleteImageView.translatesAutoresizingMaskIntoConstraints = false
        deleteImageView.centerYAnchor.constraint(equalTo: underContainerView.centerYAnchor, constant: 0).activate()
        deleteImageView.trailingAnchor.constraint(equalTo: underContainerView.trailingAnchor, constant: -9).activate()
        deleteImageView.widthAnchor.constraint(equalToConstant: 24).activate()
        deleteImageView.heightAnchor.constraint(equalToConstant: 24).activate()
        
        /// Container Layout
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 6).activate()
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).activate()
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).activate()
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).activate()
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 76).activate()
        
        /// cardImageView Layout
        containerView.addSubview(cardImageView)
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).activate()
        cardImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).activate()
        cardImageView.widthAnchor.constraint(equalToConstant: 44).activate()
        cardImageView.heightAnchor.constraint(equalToConstant: 44).activate()
        
        containerView.addSubview(checkBox)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).activate()
        checkBox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).activate()
        checkBox.widthAnchor.constraint(equalToConstant: 24).activate()
        checkBox.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(warningImageView)
        warningImageView.translatesAutoresizingMaskIntoConstraints = false
        warningImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).activate()
        warningImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).activate()
        warningImageView.widthAnchor.constraint(equalToConstant: 24).activate()
        warningImageView.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).activate()
        titleLabel.leadingAnchor.constraint(equalTo: cardImageView.trailingAnchor, constant: 16).activate()
        titleLabel.trailingAnchor.constraint(equalTo: checkBox.leadingAnchor, constant: -16).activate()
        titleLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).activate()
        descriptionLabel.leadingAnchor.constraint(equalTo: cardImageView.trailingAnchor, constant: 16).activate()
        descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).activate()
        descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).activate()
    }
    
    func configure(model: NotificationServiceResponse, readMode: Bool) {
        titleLabel.text = model.title
        descriptionLabel.text = model.body
        cardImageView.sd_setImage(with: URL(string: model.smallThumbnail ?? "")!)
        
        model.priority == 1 ? setAsWarning() :
        model.status == "UNREAD" ? setAsNormal() : setAsRead()
    }
    
    private func setAsWarning() {
        titleLabel.textColor = AppColor.warning.color
        containerView.layer.borderColor = AppColor.warning.cgColor
        warningCase = true
        warningImageView.isHidden = false
    }
    
    private func setAsNormal() {
        titleLabel.textColor = AppColor.label.color
        containerView.layer.borderColor = AppColor.tint.cgColor
        warningImageView.isHidden = true
    }
    
    private func setAsRead() {
        titleLabel.textColor = AppColor.readState.color
        containerView.layer.borderColor = AppColor.readState.cgColor
        descriptionLabel.textColor = AppColor.readState.color
        warningImageView.isHidden = true
    }
}

extension NotificationTableViewCell {
    func updateSelection(isSelectionMode: Bool, animated: Bool) {
        checkBox.isHidden = !isSelectionMode
        canSwipe = !isSelectionMode
        warningImageView.isHidden = !isSelectionMode ? !warningCase : true
       
        let selectionStateImage = isSelected ? Image.iconCheckmarkSelected : Image.iconCheckmarkNotSelected
        checkBox.image = selectionStateImage.image
    }
}
