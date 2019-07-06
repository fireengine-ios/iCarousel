//
//  PhotoVideoDetailCell.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import WebKit


protocol PhotoVideoDetailCellDelegate: class {
    func tapOnSelectedItem()
    func tapOnCellForFullScreen()
}

final class PhotoVideoDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var playVideoButton: UIButton!
    
    private lazy var webView = WKWebView(frame: .zero)
    
    weak var delegate: PhotoVideoDetailCellDelegate?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionFullscreenTapGesture))
        gesture.require(toFail: imageScrollView.doubleTapGesture)
        gesture.delegate = self
        return gesture
    }()
    
    private var isNeedToUpdateWebView = true
    private var currentItemId = ""
    
    private var doubleTapWebViewGesture: UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.addSubview(webView)
        
        if #available(iOS 11.0, *) {
            imageScrollView.contentInsetAdjustmentBehavior = .never
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        backgroundColor = UIColor.clear
        imageScrollView.delegate = self
        imageScrollView.imageView.delegate = self
        
        if let zoomGesture = webView.doubleTapZoomGesture {
            doubleTapWebViewGesture = zoomGesture
            tapGesture.require(toFail: zoomGesture)
        }
        
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func actionFullscreenTapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.tapOnCellForFullScreen()
    }
    
    private var oldFrame = CGRect.zero
    
    override func layoutSubviews() {
        /// fixed bug in iOS 11: setNavigationBarHidden calls cell layout
        if oldFrame != frame {
            oldFrame = frame
            super.layoutSubviews()
            layoutIfNeeded()
            webView.frame = contentView.frame
            imageScrollView.updateZoom()
        }
    }
    
    func setObject(object: Item) {
        if isNeedToUpdateWebView, object.uuid == currentItemId {
            return
        }
        
        webView.isHidden = true
        imageScrollView.image = nil
        playVideoButton.isHidden = true
        isNeedToUpdateWebView = false
        currentItemId = object.uuid
        
        if object.fileType == .video || object.fileType == .image {
            imageScrollView.imageView.loadImage(with: object, isOriginalImage: true)
            playVideoButton.isHidden = (object.fileType != .video)
            tapGesture.isEnabled = (object.fileType != .video)
            
        } else if object.fileType != .audio, object.fileType.isSupportedOpenType {
            isNeedToUpdateWebView = true
            imageScrollView.imageView.isHidden = true
            webView.isHidden = false
            webView.clearPage()
            if object.fileType.isDocument, let preview = object.metaData?.documentPreviewURL {
                webView.navigationDelegate = self
                webView.load(URLRequest(url: preview))
            } else if let url = object.urlToFile {
                webView.navigationDelegate = self
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    @IBAction private func onPlayVideoButton() {
        delegate?.tapOnSelectedItem()
    }
    
    deinit {
        webView.navigationDelegate = nil
        webView.stopLoading()
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

extension PhotoVideoDetailCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.delegate = self
    }
}

extension PhotoVideoDetailCell: LoadingImageViewDelegate {
    func onImageLoaded(image: UIImage?) {
        imageScrollView.image = image
        imageScrollView.updateZoom()
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
