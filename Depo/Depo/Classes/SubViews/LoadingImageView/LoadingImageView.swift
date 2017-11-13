//
//  LoadingImageView.swift
//  Depo
//
//  Created by Oleg on 21.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol LoadingImageViewDelegate: class{
    func onImageLoaded()
    func onLoadingImageCanceled()
}

class LoadingImageView: UIImageView {

    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var url: URL?
    var path: PathForItem?
    
    var cornerView: UIView?
    
    weak var delegate: LoadingImageViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (cornerView == nil){
            cornerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            
            cornerView!.backgroundColor = UIColor.clear
            cornerView!.layer.borderColor = ColorConstants.darcBlueColor.cgColor
            cornerView!.layer.borderWidth = 2
        }
        
        addSubview(activity)
        activity.center = center
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: activity, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    fileprivate func checkIsNeedCancelRequest(){
        if (path != nil){
            FilesDataSource().cancelImgeRequest(path: path!)
            path = nil
            delegate?.onLoadingImageCanceled()
        }
    }
    
    func loadImage(with object: Item?, isOriginalImage: Bool) {
        
        self.image = nil
        guard let object = object else {
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            return
        }
        
        activity.startAnimating()
        let path_: PathForItem = PathForItem.remoteUrl(url)
        path = path_
        FilesDataSource().getImage(for: object, isOriginal: isOriginalImage) { [weak self] image in
            if self?.path == path_{
                self?.activity.stopAnimating()
                self?.image = image
                self?.path = nil
                self?.delegate?.onImageLoaded()
            }
        }
    }
    
    func loadImageByURL(url: URL?){
        self.image = nil
        if (url == nil) {
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            
            return
        }
        
        activity.startAnimating()
        let path_: PathForItem = PathForItem.remoteUrl(url)
        path = path_
        FilesDataSource().getImage(patch: PathForItem.remoteUrl(url), compliteImage: {[weak self] (image) in
            if self?.path == path_{
                self?.activity.stopAnimating()
                self?.image = image
                self?.path = nil
                self?.delegate?.onImageLoaded()
            }
        })
    }
    
    func loadImageForItem(object: Item?){
        self.image = nil
        if (object == nil){
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            
            return
        }
        
        activity.startAnimating()
        path = object!.patchToPreview
        FilesDataSource().getImage(patch: object!.patchToPreview) { [weak self] (image) in
            if self?.path == object!.patchToPreview{
                self?.activity.stopAnimating()
                self?.image = image
                self?.path = nil
                self?.delegate?.onImageLoaded()
            }
        }
    }
    
    func loadImageByPath(path_ : PathForItem?){
        self.image = nil
        if (path_ == nil){
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            
            return
        }
        
        activity.startAnimating()
        path = path_
        FilesDataSource().getImage(patch: path_!) { [weak self] (image) in
            if self?.path == path_{
                self?.activity.stopAnimating()
                self?.image = image
                self?.path = nil
                self?.delegate?.onImageLoaded()
            }
        }
    }
    
    func setBorderVisibility(visibility: Bool){
        if (visibility){
            addSubview(cornerView!)
        }else{
            cornerView!.removeFromSuperview()
        }
    }

}
