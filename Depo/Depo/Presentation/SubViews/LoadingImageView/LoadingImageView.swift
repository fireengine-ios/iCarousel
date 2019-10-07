//
//  LoadingImageView.swift
//  Depo
//
//  Created by Oleg on 21.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage

protocol LoadingImageViewDelegate: class {
    func onImageLoaded(image: UIImage?)
    func onLoadingImageCanceled()
}
extension LoadingImageViewDelegate {
    func onImageLoaded(image: UIImage?) {}
    func onLoadingImageCanceled() {}
}

class LoadingImageView: UIImageView {

    let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var url: URL?
    var path: PathForItem?
    private var downloadedGifImage: UIImage?
    private var filesDataSource = FilesDataSource()
    
    var cornerView: UIView?
    
    weak var delegate: LoadingImageViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (cornerView == nil) {
            let newCornerView = UIView()
            newCornerView.translatesAutoresizingMaskIntoConstraints = false
            newCornerView.backgroundColor = UIColor.clear
            newCornerView.layer.borderColor = ColorConstants.darkBlueColor.cgColor
            newCornerView.layer.borderWidth = 2
            cornerView = newCornerView
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
    
    override func startAnimating() {
        activity.startAnimating()
    }
    
    override func stopAnimating() {
        activity.stopAnimating()
    }
    
    func checkIsNeedCancelRequest() {
        if let path = path {
            if let url = url {
                filesDataSource.cancelRequest(url: url)
            } else {
                filesDataSource.cancelImgeRequest(path: path)
            }
            
            self.path = nil
            url = nil
            delegate?.onLoadingImageCanceled()
        }
    }
    
    func loadImage(with object: Item?, isOriginalImage: Bool) {
        guard let object = object, path != object.patchToPreview else {
            return
        }
        
        self.image = nil
        checkIsNeedCancelRequest()
        path = object.patchToPreview
        activity.startAnimating()
        url = filesDataSource.getImage(for: object, isOriginal: isOriginalImage) { [weak self] image in
            if self?.path == object.patchToPreview {
                self?.finishImageLoading(image)
            }
        }
    }
    
    func loadImageByURL(url: URL?) {
        self.image = nil
        if (url == nil) {
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            
            return
        }
        
        activity.startAnimating()
        let path_: PathForItem = PathForItem.remoteUrl(url)
        path = path_
        self.url = filesDataSource.getImage(patch: PathForItem.remoteUrl(url), completeImage: { [weak self] image in
            if self?.path == path_ {
                self?.finishImageLoading(image)
            }
        })
    }
    
    private let privateQueue = DispatchQueue.global(qos: .userInitiated)
    
    func loadImageForItem(object: Item?, smooth: Bool = false) {
        if !smooth {
            self.image = nil
        }
        
        guard let object = object else {
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            return
        }
        
        if !smooth {
            activity.startAnimating()
        }
        privateQueue.async { [weak self] in
            self?.path = object.patchToPreview
            
            self?.url = self?.filesDataSource.getImage(patch: object.patchToPreview) { [weak self] image in
                if self?.path == object.patchToPreview {
                    self?.finishImageLoading(image, withAnimation: smooth)
                }
            }
        }
        
    }
    
    func loadImageByPath(path_: PathForItem?) {
        self.image = nil
        
        guard let unwrapedPath = path_ else {
            checkIsNeedCancelRequest()
            activity.stopAnimating()
            return
        }
        
        activity.startAnimating()
        path = unwrapedPath
        
        switch unwrapedPath {
        case .remoteUrl(let url):
            self.sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) {[weak self] image, error, cacheType, url in
                self?.finishImageLoading(image)
            }
        default:
            finishImageLoading(nil)
        }
    }
    
    func loadGifImageFromURL(url: URL?) {
        guard let url = url else {
            return
        }
        
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in

            do {
                let data = try Data(contentsOf: url)
                self?.downloadedGifImage = UIImage.sd_animatedGIF(with: data)
                DispatchQueue.main.async { [weak self] in
                    if let `self` = self{
                        self.image = self.downloadedGifImage
                    }
                }
            } catch {
                return
            }
        
            
            
            
//            let gif = UIImage.gifImageWithURL(gifUrl: url.absoluteString)
//            DispatchQueue.main.async { [weak self] in
//                self?.image = gif
//            }
        }
        
        
//        sd_cancelCurrentImageLoad()
//        sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) {[weak self] image, error, cacheType, url in
//            guard let image = image, let data = UIImagePNGRepresentation(image) else {
//                return
//            }
//
//            if ImageFormat.get(from: data) != .gif {
//                self?.image = image
//                return
//            }
//
//            guard let nsdata = data as NSData? else {
//                return
//            }
//
//            let gif = UIImage.gifImageWithData(data: nsdata)
//            self?.image = gif
//        }
    }
    
    func showDownloadedGif() {
        image = nil
        if let downloadedGifImage = downloadedGifImage {
            image = downloadedGifImage
        }
    }
    
    func setBorderVisibility(visibility: Bool) {
        if (visibility) {
            guard let cornerView = cornerView else {
                return
            }
            
            addSubview(cornerView)
            cornerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            cornerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            cornerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            cornerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        } else {
            cornerView?.removeFromSuperview()
        }
    }
    
    private func finishImageLoading(_ image: UIImage?, withAnimation: Bool = false) {
        self.path = nil
        self.url = nil
        DispatchQueue.toMain { [weak self] in
            guard let `self` = self else {
                return
            }
            self.activity.stopAnimating()
            if withAnimation {
                UIView.transition(
                    with: self,
                    duration: NumericConstants.animationDuration,
                    options: .transitionCrossDissolve,
                    animations: { [weak self] in
//                        self?.image = image
                    }, completion: { [weak self] _ in
                        self?.image = image
                })
            } else {
                self.image = image
            }
            self.delegate?.onImageLoaded(image: image)
        }
        
    }

}
