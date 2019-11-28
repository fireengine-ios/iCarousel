//
//  LoadingImageView.swift
//  Depo
//
//  Created by Oleg on 21.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyGif

protocol LoadingImageViewDelegate: class {
    func onImageLoaded(image: UIImage?)
    func onLoadingImageCanceled()
}
extension LoadingImageViewDelegate {
    func onImageLoaded(image: UIImage?) {}
    func onLoadingImageCanceled() {}
}

class LoadingImageView: UIImageView {

    private let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private var url: URL?
    private var path: PathForItem?
    private var filesDataSource = FilesDataSource()
    
    private var cornerView: UIView?
    
    weak var loadingImageViewDelegate: LoadingImageViewDelegate?
    
    var originalImage:UIImage? {
        get {
            return gifImage ?? image
        }
        set {
            SwiftyGifManager.defaultManager.deleteImageView(self)
            self.clear()
            
            if let gifImage = newValue, gifImage.imageCount != nil {
                setGifImage(gifImage)
                startAnimatingGif()
            } else {
                self.image = newValue
            }
            
            self.loadingImageViewDelegate?.onImageLoaded(image: currentFrameImage)
        }
    }
    
    var currentFrameImage:UIImage? {
        return currentImage ?? image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupLayout()
    }
    
    private func setupLayout() {
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
        
        activity.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        activity.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    }
    
    func cancelLoadRequest() {
        if let url = url {
            filesDataSource.cancelRequest(url: url)
        } else if let path = path {
            filesDataSource.cancelImgeRequest(path: path)
        }
            
        path = nil
        url = nil
        loadingImageViewDelegate?.onLoadingImageCanceled()
    }
    
    func loadImage(with object: Item?) {
        guard let object = object, path != object.patchToPreview else {
            return
        }
        
        cancelLoadRequest()
        originalImage = nil
        
        path = object.patchToPreview
        activity.startAnimating()
        
        url = filesDataSource.getImageData(for: object) { [weak self] data in
            guard self?.path == object.patchToPreview else {
                return
            }

            self?.loadImage(data: data)
        }
    }
    
    func loadThumbnail(object: Item?, smooth: Bool = false) {
        guard let object = object else {
            cancelLoadRequest()
            if !smooth {
                originalImage = nil
                activity.stopAnimating()
            }
            
            return
        }
        
        loadImage(path: object.patchToPreview, smooth: smooth)
    }
    
    func loadImage(path: PathForItem, smooth: Bool = false) {
        cancelLoadRequest()
        
        if !smooth {
            originalImage = nil
            activity.startAnimating()
        }
        
        self.path = path
        self.url = filesDataSource.getImage(patch: path) { [weak self] image in
            guard self?.path == path else {
                return
            }
            
            self?.finishImageLoading(image, withAnimation: smooth)
        }
    }
    
    private func loadImage(data: Data?) {
        var image:UIImage?
        if let data = data {
            let format = ImageFormat.get(from: data)
            switch format {
            case .gif:
                image = UIImage(gifData: data)
            default:
                image = UIImage(data: data)
            }
        }
        
        finishImageLoading(image)
    }
    
    func loadImage(url: URL?) {
        guard let url = url else {
            return
        }
        
        self.url = filesDataSource.getImageData(for: url) { [weak self] data in
            guard self?.url == url else {
                return
            }
            
            self?.loadImage(data: data)
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
                    animations: nil,
                    completion: { [weak self] _ in
                        self?.originalImage = image
                })
            } else {
                self.originalImage = image
            }
        }
    }

}
