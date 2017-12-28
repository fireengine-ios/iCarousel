//
//  CollectionViewCellForPhoto.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage
import Photos

class CollectionViewCellForPhoto: BaseCollectionViewCell {
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var cloudStatusImage: UIImageView!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    
    @IBOutlet weak var selectionView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    static let borderW: CGFloat = 3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionView.layer.borderWidth = CollectionViewCellForPhoto.borderW
        selectionView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
        selectionView.alpha = 0
        
        progressView.tintColor = ColorConstants.blueColor
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? WrapData else{
            return
        }
        
        if (isAlreadyConfigured){
            return
        }
        
        progressView.isHidden = true
        
        if let item = wrappedObj as? Item{
            favoriteIcon.isHidden = !item.favorites
        }
        
        imageView.image = nil
//        activity.startAnimating()
        if wrappered.isLocalItem {
            cloudStatusImage.image = UIImage(named: "objectNotInCloud")
        } else {
            cloudStatusImage.image = UIImage()
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.imageView.sd_cancelCurrentImageLoad()
        self.isAlreadyConfigured = false
    }
    
    override func updating(){
        super.updating()
        self.backgroundColor = UIColor.white
    }
    
    override func setImage(image: UIImage?) {
        if image != nil {
            self.imageView.contentMode = .scaleAspectFill
            imageView.image = image
            isAlreadyConfigured = true
            self.backgroundColor = ColorConstants.fileGreedCellColor
            activity.stopAnimating()
        } else {
            self.imageView.contentMode = .center
            super.setImage(image: image)
        }
    }

    override func setImage(with url: URL) {
        self.imageView.contentMode = .center
        imageView.sd_setImage(with: url, placeholderImage: self.placeholderImage(), options: [.avoidAutoSetImage]) {[weak self] (image, error, cacheType, url) in
            guard error == nil else {
                print("SD_WebImage_setImage error: \(error!.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.setImage(image: image)
            }
        }
        
        isAlreadyConfigured = true
        self.backgroundColor = ColorConstants.fileGreedCellColor
    }

    override func setSelection(isSelectionActive: Bool, isSelected: Bool){
        selectionImageView.isHidden = !isSelectionActive
        selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
        
        let selection = isSelectionActive && isSelected
        UIView.animate(withDuration: NumericConstants.animationDuration) { 
            self.selectionView.alpha = selection ? 1 : 0
        }
        
    }
    
    override func placeholderImage() -> UIImage? {
        return ActivityFileType.image.image
    }
    
    class func getCellSise()->CGSize{
        return CGSize(width: 90.0, height: 90.0)
    }
    
    func setProgressForObject(progress: Float){
        progressView.isHidden = false
        progressView.setProgress(progress, animated: false)
    }
    
    func finishedUploadForObject(){
        progressView.isHidden = true
        cloudStatusImage.image = UIImage(named: "objectInCloud")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
//            if let `self` = self{
//                if self.needHideCloudImage{
//                    self.cloudStatusImage.image = UIImage()
//                }
//            }
//        }
        
    }

}
