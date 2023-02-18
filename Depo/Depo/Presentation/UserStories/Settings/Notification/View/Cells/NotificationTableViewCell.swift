//
//  NotificationTableViewCell.swift
//  Depo
//
//  Created by yilmaz edis on 10.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

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
    
    private lazy var infoImageView: UIImageView = {
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
        
        /// infoImageView Layout
        containerView.addSubview(infoImageView)
        infoImageView.translatesAutoresizingMaskIntoConstraints = false
        infoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).activate()
        infoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).activate()
        infoImageView.widthAnchor.constraint(equalToConstant: 44).activate()
        infoImageView.heightAnchor.constraint(equalToConstant: 44).activate()
        
        containerView.addSubview(checkBox)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        checkBox.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).activate()
        checkBox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).activate()
        checkBox.widthAnchor.constraint(equalToConstant: 24).activate()
        checkBox.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).activate()
        titleLabel.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 16).activate()
        titleLabel.trailingAnchor.constraint(equalTo: checkBox.leadingAnchor, constant: -16).activate()
        titleLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).activate()
        descriptionLabel.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 16).activate()
        descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8).activate()
        descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).activate()
    }
    
    func configure(model: NotificationServiceResponse, readMode: Bool) {
        titleLabel.text = model.title
        descriptionLabel.text = model.body
        infoImageView.sd_setImage(with: URL(string: model.smallThumbnail ?? "")!)
    }
}

extension NotificationTableViewCell {
    func updateSelection(isSelectionMode: Bool, animated: Bool) {
        checkBox.isHidden = !isSelectionMode
        let selectionStateImage = isSelected ? Image.iconCheckmarkSelected : Image.iconCheckmarkNotSelected
        checkBox.image = selectionStateImage.image
        
        // i will add if border needs.
//        let selection = isSelectionMode && isSelected
//        if animated {
//            UIView.animate(withDuration: NumericConstants.animationDuration) {
//                self.selectionStateView.alpha = selection ? 1 : 0
//            }
//        } else {
//            selectionStateView.alpha = selection ? 1 : 0
//        }
    }
}
