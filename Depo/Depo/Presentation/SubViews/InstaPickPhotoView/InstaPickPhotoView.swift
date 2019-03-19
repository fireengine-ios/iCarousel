//
//  InstaPickPhotoView.swift
//  Depo
//
//  Created by Raman Harhun on 1/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickPhotoViewDelegate: class {
    func didTapOnImage(_ model: InstapickAnalyze?)
}

class InstaPickPhotoView: UIView, NibInit {

    private let imageView = UIImageView()
    private let containerView = RadialGradientableView()
    
    private let pictureNotFoundStackView = UIStackView()
    
    private let pickedLabel = UILabel()
    let rateLabel = UILabel()
    
    let rateView = RadialGradientableView()
    let pickedView = RadialGradientableView()
    
    var rateViewCenterYConstraint: NSLayoutConstraint!
    var imageViewHeightConstraint: NSLayoutConstraint!
    var pickedViewCenterXConstraint: NSLayoutConstraint!
    
    var model: InstapickAnalyze?
    private weak var delegate: InstaPickPhotoViewDelegate?

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onImageTap))

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout(isIPad: Device.isIpad)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCornerRadius()
    }
    
    private func setup() {
        addGestureRecognizer(tapGesture)
        
        containerView.layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        rateView.layer.masksToBounds = true
        rateLabel.textAlignment = .center
        
        pickedView.layer.masksToBounds = true
        pickedLabel.textAlignment = .center
        
        setupCornerRadius()
        setupLabelsDesign(isIPad: Device.isIpad)
        configurePictureNotFound(fontSize: 16, imageWidth: 30, spacing: 8)
    }

    func setupLayout(isIPad: Bool) {
        
        addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalTo: heightAnchor)
        
        rateView.addSubview(rateLabel)
        
        rateView.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rateLabel.centerXAnchor.constraint(equalTo: rateView.centerXAnchor).isActive = true
        rateLabel.centerYAnchor.constraint(equalTo: rateView.centerYAnchor).isActive = true
        rateLabel.heightAnchor.constraint(equalTo: rateView.heightAnchor).isActive = true
        rateLabel.widthAnchor.constraint(equalTo: rateLabel.heightAnchor).isActive = true

        addSubview(rateView)

        rateView.widthAnchor.constraint(equalTo: rateView.heightAnchor).isActive = true
        rateView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        rateViewCenterYConstraint = rateView.centerYAnchor.constraint(equalTo: centerYAnchor)

        pickedView.addSubview(pickedLabel)

        pickedView.translatesAutoresizingMaskIntoConstraints = false
        pickedLabel.translatesAutoresizingMaskIntoConstraints = false

        pickedLabel.centerXAnchor.constraint(equalTo: pickedView.centerXAnchor).isActive = true
        pickedLabel.centerYAnchor.constraint(equalTo: pickedView.centerYAnchor).isActive = true
        pickedLabel.heightAnchor.constraint(equalTo: pickedView.heightAnchor).isActive = true
        pickedLabel.widthAnchor.constraint(equalTo: pickedView.widthAnchor).isActive = true

        addSubview(pickedView)
        
        pickedView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pickedViewCenterXConstraint = pickedView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        
        addSubview(pictureNotFoundStackView)
        
        pictureNotFoundStackView.translatesAutoresizingMaskIntoConstraints = false
        
        pictureNotFoundStackView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        pictureNotFoundStackView.topAnchor.constraint(greaterThanOrEqualTo: imageView.topAnchor).isActive = true
        pictureNotFoundStackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        pictureNotFoundStackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
    }
    
    private func setupCornerRadius() {
        containerView.layer.cornerRadius = bounds.height * 0.5
        
        rateView.layer.cornerRadius = rateView.bounds.height * 0.5
        
        imageView.layer.cornerRadius = imageView.bounds.height * 0.5
        
        pickedView.layer.cornerRadius = pickedView.bounds.height * 0.5
    }
    
    func setupLabelsDesign(isIPad: Bool) {
        rateLabel.textColor = .white
        
        pickedLabel.font = UIFont.TurkcellSaturaBolFont(size: isIPad ? 20 : 14)
        pickedLabel.textColor = .white
        pickedLabel.text = TextConstants.instaPickPickedLabel
    }
    
    func configurePictureNotFound(fontSize: CGFloat, imageWidth: CGFloat, spacing: CGFloat) {
        let pictureNotFoundImageView = UIImageView()
        
        pictureNotFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        pictureNotFoundImageView.image = UIImage(named: "instaPickPicture")
        pictureNotFoundImageView.contentMode = .scaleAspectFit
        pictureNotFoundImageView.heightAnchor.constraint(equalTo: pictureNotFoundImageView.widthAnchor, multiplier: 0.9).isActive = true
        pictureNotFoundImageView.widthAnchor.constraint(equalToConstant: imageWidth).isActive = true

        let pictureNotFoundLabel = UILabel()

        pictureNotFoundLabel.font           = UIFont.TurkcellSaturaDemFont(size: fontSize)

        pictureNotFoundLabel.text           = TextConstants.instaPickPictureNotFoundLabel
        pictureNotFoundLabel.textColor      = ColorConstants.darkBlueColor
        pictureNotFoundLabel.textAlignment  = .center
        pictureNotFoundLabel.numberOfLines  = 2
        
        pictureNotFoundLabel.adjustsFontSizeToFitWidth()
        
        pictureNotFoundStackView.axis       = .vertical
        pictureNotFoundStackView.alignment  = .center
        pictureNotFoundStackView.spacing    = spacing
        
        pictureNotFoundStackView.addArrangedSubview(pictureNotFoundImageView)
        pictureNotFoundStackView.addArrangedSubview(pictureNotFoundLabel)
        
        pictureNotFoundStackView.isHidden = true
    }
    
    //MARK: - Utility methods(public)
    func configureImageView(with model: InstapickAnalyze,
                            delegate: InstaPickPhotoViewDelegate? = nil,
                            smallPhotosCount: Int) {
        if let oldModel = self.model, let oldId = oldModel.fileInfo?.uuid, let newId = model.fileInfo?.uuid {
            ///logic for reuse this method on tap at small image (not pass if model same and reconfigure if thay are different)
            if oldId == newId {
                return
            }
        }
        
        if delegate != nil {
            self.delegate = delegate
        }
        
        self.model = model

        rateLabel.text = String(model.rank)
        
        pictureNotFoundStackView.isHidden = true
        imageView.sd_setImage(with: getPhotoUrl(), completed: { [weak self] (image, _, _, _) in
            guard let `self` = self else {
                return
            }
            
            let imageToAttach: UIImage?
            let imageViewBackgroundColor: UIColor
            let isPictureExist = (image != nil)
            
            if image == nil {
                imageToAttach = UIImage(named: "instaPickImageNotFound")
                imageViewBackgroundColor = .white
            } else {
                imageToAttach = image
                imageViewBackgroundColor = .clear
            }
            
            UIView.transition(with: self.imageView,
                              duration: NumericConstants.instaPickImageViewTransitionDuration,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.imageView.backgroundColor = imageViewBackgroundColor
                                self.imageView.image = imageToAttach
                                self.pictureNotFoundStackView.isHidden = isPictureExist
            }, completion: nil)
        })
        
        if model.isPicked {
            pickedView.isHidden = isNeedHidePickedView(hasSmallPhotos: smallPhotosCount > 0)
            
            rateView.isNeedGradient = true
            containerView.isNeedGradient = true
        } else {
            pickedView.isHidden = true
            
            rateView.isNeedGradient = false
            rateView.backgroundColor = UIColor.lrTealish
            
            containerView.isNeedGradient = false
            containerView.backgroundColor = UIColor.lrTealish
        }
    }
    
    func getImage() -> UIImage? {
        return imageView.image
    }
    
    //MARK: Inheritor methods
    func getPhotoUrl() -> URL? {
        return nil
    }
    
    func isNeedHidePickedView(hasSmallPhotos: Bool) -> Bool {
        return true
    }
    
    //MARK: Action
    @objc func onImageTap() {
        delegate?.didTapOnImage(model)
    }
}
