//
//  InstaPickPhotoView.swift
//  Depo
//
//  Created by Raman Harhun on 1/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class InstaPickPhotoView: UIView, NibInit {
    
    lazy var pickedLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    lazy var pickedView: UIView = {
        let view = UIView(frame: CGRect(x: -5, y: -5, width: 80, height: 30))
        view.layer.masksToBounds = true
         return view
     }()
    
    lazy var rateLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    lazy var rateView: UIView = {
        let view = UIView(frame: CGRect(x: -5, y: -5, width: 32, height: 32))
        view.layer.masksToBounds = true
         return view
     }()
    
    lazy var selectedImageContainer: UIView = {
        let view = UIView(frame: CGRect(x: 5, y: 5, width: 165, height: 165))
        view.layer.masksToBounds = true
         return view
     }()
    
    lazy var imageView: UIImageView = {
       let view = UIImageView()
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
         return view
     }()
    
    private let pictureNotFoundStackView = UIStackView()
    
    var model: InstapickAnalyze?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLayout(isIPad: Device.isIpad)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func setup() {
        setupLabelsDesign(isIPad: Device.isIpad)
        configurePictureNotFound(fontSize: 16, imageWidth: 30, spacing: 8)
    }

    func setupLayout(isIPad: Bool) {
        addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        imageView.addSubview(pictureNotFoundStackView)
        pictureNotFoundStackView.translatesAutoresizingMaskIntoConstraints = false
        pictureNotFoundStackView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        pictureNotFoundStackView.topAnchor.constraint(greaterThanOrEqualTo: imageView.topAnchor).isActive = true
        pictureNotFoundStackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        pictureNotFoundStackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
    }
    
    func setupLabelsDesign(isIPad: Bool) {
        rateLabel.textColor = .white
        
        pickedLabel.font = .appFont(.regular, size: isIPad ? 18 : 12)
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

        pictureNotFoundLabel.font           = UIFont.appFont(.regular, size: fontSize)

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
    func configureImageView(with model: InstapickAnalyze) {
        if let oldModel = self.model, let oldId = oldModel.fileInfo?.uuid, let newId = model.fileInfo?.uuid {
            ///logic for reuse this method on tap at small image (not pass if model same and reconfigure if thay are different)
            if oldId == newId {
                return
            }
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
        
        pickedView.isHidden = !model.isPicked
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
}
