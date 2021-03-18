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
    func tapOnCellForFullScreen()
    func imageLoadingFinished()
    func didExpireUrl()
    func preparedMediaItem(completion: @escaping ValueHandler<AVURLAsset?>)
}

final class PhotoVideoDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView! {
        willSet {
            newValue.backgroundColor = .black
        }
    }
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var placeholderImageView: UIImageView!
    @IBOutlet private weak var playerView: DetailMediaPlayerView! {
        willSet {
            newValue.isHidden = true
            newValue.backgroundColor = .black
        }
    }
    
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
        
        setupViews()
        
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

    func setup(with object: Item, isFullScreen: Bool) {
        if isNeedToUpdateWebView, object.uuid == currentItemId {
            return
        }
        
        isNeedToUpdateWebView = false
        
        currentItemId = object.uuid
        fileType = object.fileType
        placeholderImageView.isHidden = true
        
        switch fileType {
            case .video, .audio:
                backgroundColor = .clear
                imageScrollView.backgroundColor = .black
                playerView.isHidden = false
                playerView.setControls(isHidden: isFullScreen)
                imageScrollView.isHidden = true
                tapGesture.isEnabled = true
                
                if let url = object.urlToFile {
                    if !url.isExpired {
                        delegate?.imageLoadingFinished()
                        playerView.set(url: url)
                    } else {
                        delegate?.didExpireUrl()
                    }
                } else {
                    delegate?.didExpireUrl()
                }
            
            case .image:
                backgroundColor = .clear
                imageScrollView.backgroundColor = .black
                playerView.isHidden = true
                imageScrollView.isHidden = false
                imageScrollView.imageView.loadImageIncludingGif(with: object)
                imageScrollView.adjustFrameToCenter()
                tapGesture.isEnabled = true
            
            default:
                backgroundColor = .white
                playerView.isHidden = true
                
                if fileType.isSupportedOpenType {
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
    }
    
    private func setupViews() {
        imageScrollView.imageViewDelegate = self
        contentView.addSubview(webView)
        
        imageScrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        backgroundColor = UIColor.clear
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
        
        imageScrollView.isHidden = true
        placeholderImageView.isHidden = true
        
        playerView.stop()
        playerView.isHidden = true
    }
    
    @objc private func actionFullscreenTapGesture(_ gesture: UITapGestureRecognizer) {
        playerView.toggleControlsVisibility()
        delegate?.tapOnCellForFullScreen()
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
        placeholderImageView.image = WrapperedItemUtil.previewPlaceholderImage(fileType: fileType)
        imageScrollView.isHidden = true
        webView.isHidden = true
        placeholderImageView.isHidden = false
    }
}
