//
//  PhotoVideoDetailCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import WebKit

protocol PhotoVideoDetailCellDelegate: AnyObject {
    func tapOnSelectedItem()
    func tapOnCellForFullScreen()
    func imageLoadingFinished()
    func didExpireUrl()
    func itemPlaceholderFinished()
}

final class PhotoVideoDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var playVideoButton: UIButton!
    @IBOutlet private weak var placeholderImageView: UIImageView!
    
    private lazy var webView = WKWebView(frame: .zero)
    
    weak var delegate: PhotoVideoDetailCellDelegate?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionFullscreenTapGesture))
        gesture.require(toFail: imageScrollView.doubleTapGesture)
        gesture.delegate = self
        return gesture
    }()
    
    private var isNeedToUpdateWebView = true
    private var oldFrame = CGRect.zero
    private var currentItemId = ""
    private var fileType: FileType = .unknown
    
    private var doubleTapWebViewGesture: UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageScrollView.imageViewDelegate = self
        contentView.addSubview(webView)
        
        imageScrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        backgroundColor = UIColor.clear
        
        if let zoomGesture = webView.doubleTapZoomGesture {
            doubleTapWebViewGesture = zoomGesture
            tapGesture.require(toFail: zoomGesture)
        }
        
        addGestureRecognizer(tapGesture)
        
        reset()
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
    
    override func layoutSubviews() {
        /// fixed bug in iOS 11: setNavigationBarHidden calls cell layout
        if oldFrame != frame {
            oldFrame = frame
            super.layoutSubviews()
            layoutIfNeeded()
            webView.frame = contentView.frame
            imageScrollView.updateZoom()
            imageScrollView.adjustFrameToCenter()
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }
    
    func imageViewMaxY() -> CGFloat {
        return imageScrollView.getImageViewMaxY()
    }
    
    private func reset() {
        currentItemId = ""
        fileType = .unknown
        isNeedToUpdateWebView = true

        tapGesture.isEnabled = true
        
        if !webView.isHidden {
            webView.navigationDelegate = nil
            webView.scrollView.delegate = nil
            
            if webView.isLoading {
                webView.stopLoading()
            }
            
            webView.clearPage()
            webView.isHidden = true
        }
        
        playVideoButton.isHidden = true
        imageScrollView.isHidden = true
        placeholderImageView.isHidden = true
    }
    
    func setObject(object: Item) {
        if isNeedToUpdateWebView, object.uuid == currentItemId {
            return
        }
        
        isNeedToUpdateWebView = false
        
        currentItemId = object.uuid
        fileType = object.fileType
        placeholderImageView.isHidden = true
        
        if fileType == .video || fileType == .image {
            imageScrollView.isHidden = false
            imageScrollView.imageView.loadImageIncludingGif(with: object)
            imageScrollView.adjustFrameToCenter()
            playVideoButton.isHidden = (fileType != .video)
            tapGesture.isEnabled = (fileType != .video)
        } else if fileType != .audio, fileType.isSupportedOpenType {
            webView.isHidden = false
            webView.navigationDelegate = self
            webView.clearPage()

            let loadURL: URL?
            if fileType.isDocument, let preview = object.metaData?.documentPreviewURL {
                loadURL = preview
            } else if let url = object.urlToFile {
                loadURL = url
            } else {
                loadURL = nil
            }
            
            if let url = loadURL, object.isOwner || !url.isExpired {
                isNeedToUpdateWebView = true
                webView.load(URLRequest(url: url))
            } else {
                delegate?.didExpireUrl()
            }
        } else {
            setPlaceholder()
        }
    }
    
    @objc private func actionFullscreenTapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.tapOnCellForFullScreen()
    }
    
    @IBAction private func onPlayVideoButton() {
        delegate?.tapOnSelectedItem()
    }

}

extension PhotoVideoDetailCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == webView.scrollView {
            return webView.scrollView.subviews.first
        }
        return nil
    }
}

extension PhotoVideoDetailCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.delegate = self
        self.webView = webView
        delegate?.imageLoadingFinished()
    }
}

extension PhotoVideoDetailCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGesture, otherGestureRecognizer == doubleTapWebViewGesture {
            return false
        }
        return true
    }
}

extension PhotoVideoDetailCell: ImageScrollViewDelegate {
    func imageViewFinishedLoading() {
        delegate?.imageLoadingFinished()
    }
    
    func onImageLoaded(image: UIImage?) {
        if image == nil, fileType != .video {
            setPlaceholder()
        } else {
            placeholderImageView.isHidden = true
            imageScrollView.isHidden = !(fileType == .video || fileType == .image)
        }
    }
    
    private func setPlaceholder() {
        placeholderImageView.image = WrapperedItemUtil.privateSharePlaceholderImage(fileType: fileType)
        imageScrollView.isHidden = true
        webView.isHidden = true
        placeholderImageView.isHidden = false
        delegate?.itemPlaceholderFinished()
    }
}
