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
    private var oldFrame = CGRect.zero
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
    
    private func reset() {
        currentItemId = ""
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
    }
    
    func setObject(object: Item) {
        if isNeedToUpdateWebView, object.uuid == currentItemId {
            return
        }
        
        isNeedToUpdateWebView = false
        
        currentItemId = object.uuid
        
        if object.fileType == .video || object.fileType == .image {
            imageScrollView.isHidden = false
            imageScrollView.imageView.loadImageIncludingGif(with: object)
            imageScrollView.adjustFrameToCenter()
            playVideoButton.isHidden = (object.fileType != .video)
            tapGesture.isEnabled = (object.fileType != .video)
        } else if object.fileType != .audio, object.fileType.isSupportedOpenType {
            isNeedToUpdateWebView = true
            
            webView.isHidden = false
            webView.navigationDelegate = self
            webView.clearPage()

            let loadURL: URL?
            if object.fileType.isDocument, let preview = object.metaData?.documentPreviewURL {
                loadURL = preview
            } else if let url = object.urlToFile {
                loadURL = url
            } else {
                loadURL = nil
            }
            
            if let url = loadURL {
                webView.load(URLRequest(url: url))
            }
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
