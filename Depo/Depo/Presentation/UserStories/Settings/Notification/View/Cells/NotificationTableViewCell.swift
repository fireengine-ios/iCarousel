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
    
    private lazy var checkBox: UIButton = {
        let view = UIButton()
        
        view.isHidden = true
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderColor = AppColor.tint.cgColor
        view.layer.borderWidth = 2
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
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        
        switch gestureRecognizer.state {
        case .changed:
            // Prevent it from sliding to the right
            guard translation.x < 0 else { return }
            
            transform = CGAffineTransform(translationX: translation.x , y: 0)
        case .ended:
            if translation.x < -bounds.size.width / 2 {
                deleteHandler?()
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                }
            }
        default:
            break
        }
    }
    
    private func setLayout() {
        
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
        descriptionLabel.text = "Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp..Lorem ıpsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp.."
        //infoImageView.sd_setImage(with: URL(string: model.largeThumbnail ?? "")!)
        infoImageView.sd_setImage(with: URL(string: "https://avatars.githubusercontent.com/u/15719990?s=400&u=766c3d645df09b0c562e71affd899b296aa1d59b&v=4")!)
        
        checkBox.isHidden = !readMode
        checkBox.setImage(Image.iconSelectCheck.image, for: .normal)
        // containerView.layer.borderColor = ...
    }
}
