//
//  InstaPickPhotoView.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickPhotoViewDelegate {
    func didTapOnImage(_ id: String)
}

final class InstaPickPhotoView: UIView {
    
    private static let bigViewId = "BigView"
    
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

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setupLayers()
    }
    
    //MARK: - Utility methods(private)
    private func setupFonts() {
        let isBigView = restorationIdentifier == InstaPickPhotoView.bigViewId
        pickedLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        pickedLabel.textColor = .white
        pickedLabel.text = TextConstants.instaPickPickedLabel
        
        rateLabel.font = UIFont.TurkcellSaturaBolFont(size: isBigView ? 14 : 8)
        rateLabel.textColor = .white
    }

    private func setup() {
        imageView.contentMode = .scaleAspectFill
        
        setupFonts()
        setupLayers()
    }
    
    private func setupLayers() {
        imageView.layer.cornerRadius = imageView.bounds.height * 0.5

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
        
        rateView.layer.masksToBounds = true
        rateView.layer.cornerRadius = rateView.bounds.height * 0.5

        pickedView.layer.masksToBounds = true
        pickedView.layer.cornerRadius = pickedView.bounds.height * 0.5
    }
    
    private func setupView() {
        let nibNamed = String(describing: InstaPickPhotoView.self)
        Bundle(for: InstaPickPhotoView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    //MARK: - Utility methods(public)
    func configureImageView(with model: InstapickAnalyze,
                            url: URL?, //tmp
                            delegate: InstaPickPhotoViewDelegate? = nil) {
        if let oldModel = self.model {
            ///logic for reuse this method on tap at small image (not pass if model same and reconfigure if thay are different)
            guard oldModel.requestIdentifier != model.requestIdentifier else { return }
        }
        
        if delegate != nil {
            self.delegate = delegate
        }
        rateLabel.text = String(model.rank)

        let isBigView = restorationIdentifier == InstaPickPhotoView.bigViewId

        let Url = isBigView ? url : url //tmp
//        let url = isBigView ? model.getLargeImageURL() : model.getSmallImageURL()
        imageView.sd_setImage(with: Url, completed: { [weak self] (image, _, _, _) in
            if image == nil {
                self?.imageView.backgroundColor = .white
                self?.imageView.image = UIImage(named: "instaPickImageNotFound")
            }
        })
        
        if !model.isPicked {
            pickedView.isHidden = true
            
            rateView.isNeedGradient = false
            rateView.backgroundColor = UIColor.lrTealish
            
            contentView.isNeedGradient = false
            contentView.backgroundColor = UIColor.lrTealish
        } else {
            pickedView.isHidden = !isBigView
            
            rateView.isNeedGradient = true
            contentView.isNeedGradient = true
        }
        
        self.model = model
    }
    
    @IBAction private func onImageTap(_ sender: Any) {
        delegate?.didTapOnImage(model?.requestIdentifier ?? "")
    }
}
