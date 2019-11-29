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

final class LoadingImageView: UIImageView {

    private let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private var url: URL?
    private var path: PathForItem?
    private let filesDataSource = FilesDataSource()
    
    private var cornerView: UIView?
    
    weak var loadingImageViewDelegate: LoadingImageViewDelegate?
    
    var originalImage: UIImage? {
        get {
            return gifImage ?? image
        }
        set {
            SwiftyGifManager.defaultManager.deleteImageView(self)
            clear()
            
            if let gifImage = newValue, gifImage.imageCount != nil {
                setGifImage(gifImage)
                startAnimatingGif()
            } else {
                image = newValue
            }
            
            loadingImageViewDelegate?.onImageLoaded(image: currentFrameImage)
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
    
    
    //MARK: - Setup
    
    private func setupLayout() {
        setupCornerView()
        setupActivityIndicator()
    }
    
    private func setupCornerView() {
        if cornerView == nil {
            let newCornerView = UIView()
            newCornerView.translatesAutoresizingMaskIntoConstraints = false
            newCornerView.backgroundColor = UIColor.clear
            newCornerView.layer.borderColor = ColorConstants.darkBlueColor.cgColor
            newCornerView.layer.borderWidth = 2
            cornerView = newCornerView
        }
    }
    
    private func setupActivityIndicator() {
        addSubview(activity)
        
        activity.center = center
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        
        activity.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        activity.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    }
    
    func set(borderIsVisible: Bool) {
           if borderIsVisible {
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
    
    
    //MARK: - Image Loading
    
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

    func loadImage(with object: Item?, smooth: Bool = false) {
        guard let path = object?.patchToPreview else {
            cancelLoadRequest()
            
            if !smooth {
                originalImage = nil
                activity.stopAnimating()
            }
            
            return
        }
        
        loadImage(with: path, smooth: smooth)
    }
    
    func loadImage(with path: PathForItem, smooth: Bool = false) {
        cancelLoadRequest()
        
        if !smooth {
            originalImage = nil
            activity.startAnimating()
        }
        
        self.path = path
        url = filesDataSource.getImage(patch: path) { [weak self] image in
            guard self?.path == path else {
                return
            }
            
            self?.finishLoading(image: image, animated: smooth)
        }
    }
    
    func loadImage(with url: URL?, animated: Bool = false) {
        guard let url = url else {
            return
        }
        
        self.url = filesDataSource.getImageData(for: url) { [weak self] data in
            guard self?.url == url else {
                return
            }
            
            self?.finishLoading(data: data, animated: animated)
        }
    }
    
    
    private func finishLoading(data: Data?, animated: Bool = false) {
        var image: UIImage?
        if let data = data {
            let format = ImageFormat.get(from: data)
            switch format {
            case .gif:
                image = UIImage(gifData: data)
            default:
                image = UIImage(data: data)
            }
        }
        
        finishLoading(image: image, animated: animated)
    }
    
    private func finishLoading(image: UIImage?, animated: Bool = false) {
        path = nil
        url = nil
        
        DispatchQueue.toMain { [weak self] in
            guard let `self` = self else {
                return
            }
            self.activity.stopAnimating()
            if animated {
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
