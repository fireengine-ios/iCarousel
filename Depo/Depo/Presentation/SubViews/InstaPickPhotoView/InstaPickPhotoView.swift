//
//  InstaPickPhotoView.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickPhotoViewDelegate {
    func didTapOnImage(_ model: InstapickAnalyze?)
}

final class InstaPickPhotoView: UIView {
    
    private enum ConstraintConstants {
        static let rateConstant: CGFloat      = isIPad ? 10.25 : 7.75
        static let imageViewConstant: CGFloat = isIPad ? 26.5 : 22.0
        static let containerConstant: CGFloat = isIPad ? 27.5 : 22.5
    }
    
    private static let bigViewId = "bigView"
    private static let isIPad = Device.isIpad
    
    @IBOutlet private var view: UIView!
    
    @IBOutlet private weak var contentView: RadialGradientableView!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var pickedView: RadialGradientableView!
    @IBOutlet private weak var pickedLabel: UILabel!
    
    @IBOutlet private weak var rateView: RadialGradientableView!
    @IBOutlet private weak var rateLabel: UILabel!
    
    var delegate: InstaPickPhotoViewDelegate?
    var model: InstapickAnalyze?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        setupLayers()
    }
    
    //MARK: - Utility methods(private)
    private func setupFonts() {
        let isIPad = Device.isIpad
        let isBigView = restorationIdentifier == InstaPickPhotoView.bigViewId
        
        let bigViewFontSize: CGFloat = isIPad ? 20 : 14
        let smallViewFontSize: CGFloat = isIPad ? 14 : 10
        
        let rateFontSize: CGFloat = isBigView ? bigViewFontSize : smallViewFontSize
        
        pickedLabel.font = UIFont.TurkcellSaturaBolFont(size: bigViewFontSize)
        pickedLabel.textColor = .white
        pickedLabel.text = TextConstants.instaPickPickedLabel
        
        rateLabel.font = UIFont.TurkcellSaturaBolFont(size: rateFontSize)
        rateLabel.textColor = .white
    }

    private func setup() {
        setNeedsLayout()
        layoutIfNeeded()
        
        imageView.contentMode = .scaleAspectFill
        
        contentView.layer.masksToBounds = true
        rateView.layer.masksToBounds = true
        pickedView.layer.masksToBounds = true

        setupLayers()
        setupFonts()
    }
    
    private func setupLayers() {
        ///Big view may change size on different iPhone's screen width
        if restorationIdentifier == InstaPickPhotoView.bigViewId {
            imageView.layer.cornerRadius = imageView.bounds.height * 0.5

            contentView.layer.cornerRadius = contentView.bounds.height * 0.5
            
            rateView.layer.cornerRadius = rateView.bounds.height * 0.5
            
            pickedView.layer.cornerRadius = pickedView.bounds.height * 0.5
        } else {
            ///has static size for iPhone/iPad + fix wrong layer corner radius
            imageView.layer.cornerRadius = ConstraintConstants.imageViewConstant
            
            contentView.layer.cornerRadius = ConstraintConstants.containerConstant
            
            rateView.layer.cornerRadius = ConstraintConstants.rateConstant
        }
    }
    
    private func setupView() {
        let nibNamed = String(describing: InstaPickPhotoView.self)
        Bundle(for: InstaPickPhotoView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else {
            return
        }
        
        view.frame = bounds
        
        addSubview(view)
    }
    
    //MARK: - Utility methods(public)
    func configureImageView(with model: InstapickAnalyze,
                            delegate: InstaPickPhotoViewDelegate? = nil) {
        if let oldModel = self.model, let oldId = oldModel.fileInfo?.uuid, let newId = model.fileInfo?.uuid {
            ///logic for reuse this method on tap at small image (not pass if model same and reconfigure if thay are different)
            if oldId == newId {
                return
            }
        }
        
        if delegate != nil {
            self.delegate = delegate
        }
        rateLabel.text = String(model.rank)

        let isBigView = restorationIdentifier == InstaPickPhotoView.bigViewId

        let url = isBigView ? model.getLargeImageURL() : model.getSmallImageURL()
        imageView.sd_setImage(with: url, completed: { [weak self] (image, _, _, _) in
            guard let `self` = self else {
                return
            }
            
            let imageToAttach: UIImage?
            let imageViewBackgroundColor: UIColor
            
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
            }, completion: nil)
        })
        
        if model.isPicked {
            pickedView.isHidden = !isBigView
            
            rateView.isNeedGradient = true
            contentView.isNeedGradient = true
        } else {
            pickedView.isHidden = true
            
            rateView.isNeedGradient = false
            rateView.backgroundColor = UIColor.lrTealish
            
            contentView.isNeedGradient = false
            contentView.backgroundColor = UIColor.lrTealish
        }
        
        self.model = model
    }
    
    func getImage() -> UIImage? {
        return imageView.image
    }
    
    //MARK: Action
    @IBAction private func onImageTap(_ sender: Any) {
        delegate?.didTapOnImage(model)
    }
}
