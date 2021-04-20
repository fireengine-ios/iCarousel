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
    func loadingFinished()
    func didExpireUrl(at index: Int, isFull: Bool)
}

final class PhotoVideoDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView! {
        willSet {
            newValue.backgroundColor = .black
        }
    }
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var placeholderImageView: UIImageView!
    @IBOutlet private weak var gradientView: MediaContentGradientView! {
        willSet {
            newValue.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet private weak var playerView: DetailMediaPlayerView! {
        willSet {
            newValue.delegate = self
            newValue.isHidden = true
            newValue.backgroundColor = .black
        }
    }
    
    private lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero)
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        return view
    }()
    
    private let webViewTopInset: CGFloat = 60 + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
    
    weak var delegate: PhotoVideoDetailCellDelegate?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionFullscreenTapGesture))
        gesture.require(toFail: imageScrollView.doubleTapGesture)
        gesture.delegate = self
        return gesture
    }()
    
    private var isGradientHidden = true
    private var isNeedToUpdateWebView = true
    private var isNeedToUpdateUrl = false
    private var oldFrame = CGRect.zero
    private var currentItemId = ""
    private var fileType: FileType = .unknown {
        didSet {
            isGradientHidden = !fileType.isContained(in: [.audio, .video, .image])
        }
    }
    
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
            super.layoutSubviews()
            layoutIfNeeded()
            
            imageScrollView.updateZoom()
            imageScrollView.adjustFrameToCenter()
        }
        
        updateWebViewFrame()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reset()
    }

    func setup(with object: Item, index: Int, isFullScreen: Bool) {
        if isNeedToUpdateWebView, object.uuid == currentItemId {
            return
        }
        
        isNeedToUpdateWebView = false
        
        currentItemId = object.uuid
        fileType = object.fileType
        gradientView.set(isHidden: isFullScreen || isGradientHidden, animated: false)
        
        switch fileType {
            case .video:
                
                backgroundColor = .clear
                
                guard let url = object.metaData?.videoPreviewURL, !url.isExpired else {
                    processMissingUrl(at: index, isFullRequired: false)
                    return
                }
                
                imageScrollView.backgroundColor = .black
                playerView.isHidden = false
                playerView.setControls(isHidden: isFullScreen)
                tapGesture.isEnabled = true
                
                playerView.delegate = self
                playerView.set(url: url)
                
            case .audio:
                
                backgroundColor = .clear
                
                showPlaceholder()
                
                guard let url = object.urlToFile, !url.isExpired else {
                    processMissingUrl(at: index, isFullRequired: true)
                    return
                }
                
                imageScrollView.backgroundColor = .black
//                imageScrollView.imageView.loadImageIncludingGif(with: object)
                playerView.isHidden = false
                playerView.setControls(isHidden: isFullScreen)
                tapGesture.isEnabled = true
                
                playerView.delegate = self
                playerView.set(url: url)
                
            case .image:
                
                backgroundColor = .clear
                
                guard let url = object.metaData?.largeUrl, !url.isExpired else {
                    processMissingUrl(at: index, isFullRequired: false)
                    return
                }
                
                imageScrollView.backgroundColor = .black
                imageScrollView.isHidden = false
                imageScrollView.imageView.loadImageIncludingGif(with: object)
                imageScrollView.adjustFrameToCenter()
                tapGesture.isEnabled = true
            
            default:
                backgroundColor = .white
                
                if fileType.isSupportedOpenType {
                    
                    guard let url = object.urlToFile, !url.isExpired else {
                        processMissingUrl(at: index, isFullRequired: true)
                        return
                    }
                    
                    webView.isHidden = false
                    webView.navigationDelegate = self
                    webView.clearPage()
                    webView.load(URLRequest(url: url))
                    
                } else {
                    showPlaceholder()
                    hidePreviewViews()
                    showNoPreviewMessage()
                }
        }
    }
    
    func update(with object: Item, index: Int, isFullScreen: Bool) {
        guard !isNeedToUpdateUrl else {
            return
        }
        
        setup(with: object, index: index, isFullScreen: isFullScreen)
    }
    
    func didEndDisplaying() {
        playerView.stop()
    }
    
    private func updateWebViewFrame() {
        let safeAreaBottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        let originUnderSafe = CGPoint(x: contentView.frame.origin.x, y: contentView.frame.origin.y + webViewTopInset)
        let sizeWithoutSafe = CGSize(width: contentView.frame.width, height: contentView.frame.height - webViewTopInset - safeAreaBottom)
        webView.frame = CGRect(origin: originUnderSafe, size: sizeWithoutSafe)
    }
    
    private func processMissingUrl(at index: Int, isFullRequired: Bool) {
        if !isNeedToUpdateUrl {
            isNeedToUpdateUrl = true
            delegate?.didExpireUrl(at: index, isFull: isFullRequired)
            return
        }
        
        isNeedToUpdateUrl = false
        showPlaceholder()
        hidePreviewViews()
        showNoPreviewMessage()
    }
    
    private func setupViews() {
        imageScrollView.imageViewDelegate = self
        contentView.addSubview(webView)
        
        imageScrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    private func reset() {
        currentItemId = ""
        fileType = .unknown
        isNeedToUpdateWebView = true
        isNeedToUpdateUrl = false

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
        playerView.clearArtwork()
        playerView.delegate = nil
        playerView.isHidden = true
    }
    
    @objc private func actionFullscreenTapGesture(_ gesture: UITapGestureRecognizer) {
        playerView.toggleControlsVisibility()
        if !isGradientHidden {
            gradientView.toggleVisibility()
        }
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
        delegate?.loadingFinished()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showPlaceholder()
        hidePreviewViews()
        showNoPreviewMessage()
    }
}

extension PhotoVideoDetailCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGesture {
            return !(otherGestureRecognizer == doubleTapWebViewGesture || otherGestureRecognizer is UIPanGestureRecognizer)
        }
        
        return true
    }
}

extension PhotoVideoDetailCell: ImageScrollViewDelegate {
    func imageViewFinishedLoading(hasData: Bool) {
        placeholderImageView.isHidden = true
        if !hasData {
            showNoPreviewMessage()
        }
        
        delegate?.loadingFinished()
    }
    
    func onImageLoaded(image: UIImage?) {
        if image == nil {
            showPlaceholder()
            hidePreviewViews()
        } else {
            placeholderImageView.isHidden = true
            imageScrollView.isHidden = false
        }
    }
    private func showNoPreviewMessage() {
        delegate?.loadingFinished()
        
        switch fileType {
            case .image:
                SnackbarManager.shared.show(type: SnackbarType.action, message: TextConstants.photoNoPreview)
                
            case .audio:
                SnackbarManager.shared.show(type: SnackbarType.action, message: TextConstants.audioNoPreview)
                
            default:
                SnackbarManager.shared.show(type: SnackbarType.action, message: TextConstants.documentNoPreview)
        }
    }
    
    private func showPlaceholder() {
        placeholderImageView.image = WrapperedItemUtil.previewPlaceholderImage(fileType: fileType)
        placeholderImageView.isHidden = false
    }
    
    private func hidePreviewViews() {
        imageScrollView.isHidden = true
        webView.isHidden = true
        playerView.isHidden = true
    }
}


extension PhotoVideoDetailCell: DetailMediaPlayerViewDelegate {
    func playerHasData() {
        delegate?.loadingFinished()
    }
    
    func playerIsFailed() {
        delegate?.loadingFinished()
        showPlaceholder()
        hidePreviewViews()
        showNoPreviewMessage()
    }
    
    func artworkIsLoaded() {
        placeholderImageView.isHidden = true
    }
}
