//
//  PhotoVideoDetailCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoDetailCellDelegate: class {
    func tapOnSelectedItem()
    func pageToRight()
    func pageToLeft()
}

final class PhotoVideoDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var playVideoButton: UIButton!
    @IBOutlet private weak var webView: UIWebView!
    
    private var index: Int = -1
    
    weak var delegate: PhotoVideoDetailCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        webView.scalesPageToFit = true /// enable zoom
        imageScrollView.delegate = self
        imageScrollView.imageView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        imageScrollView.updateZoom()
    }
    
    func setObject(object:Item, index: Int) {
        webView.isHidden = true
        imageScrollView.image = nil
        playVideoButton.isHidden = true
        self.index = index
        
        if object.fileType == .video || object.fileType == .image {
            imageScrollView.imageView.loadImage(with: object, isOriginalImage: true)
            playVideoButton.isHidden = !(object.fileType == FileType.video)
            
        } else if object.fileType != .audio, object.fileType.isUnSupportedOpenType {
            imageScrollView.imageView.isHidden = true
            webView.isHidden = false
            webView.clearPage()
            if let url = object.urlToFile {
                webView.delegate = self
                webView.loadRequest(URLRequest(url: url))
            }
        }
    }
    
    @IBAction private func onPlayVideoButton() {
        delegate?.tapOnSelectedItem()
    }
}

extension PhotoVideoDetailCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == imageScrollView {
            return imageScrollView.imageView
        } else if scrollView == webView.scrollView {
            return webView.scrollView.subviews.first
        }
        return nil
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == imageScrollView {
            imageScrollView.adjustFrameToCenter()
        }
    }
}

extension PhotoVideoDetailCell: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.scrollView.delegate = self
    }
}

extension PhotoVideoDetailCell: LoadingImageViewDelegate {
    func onImageLoaded(image: UIImage?) {
        imageScrollView.image = image
        imageScrollView.updateZoom()
    }
}
