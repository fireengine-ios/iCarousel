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
    func recognizeTextButtonTapped(image: UIImage, isActive: Bool)
}

final class PhotoVideoDetailCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var playVideoButton: UIButton!
    @IBOutlet private weak var placeholderImageView: UIImageView!

    let recognizeTextButton = RecognizeTextButton()
    private var recognizeTextButtonBottomConstraint: NSLayoutConstraint?
    
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
    private var isLocalItem = false
    
    private var doubleTapWebViewGesture: UITapGestureRecognizer?

    private var currentTextSelectionInteraction: ImageTextSelectionInteraction?

    var isRecognizeTextEnabled = false

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

        setupRecognizeTextButton()

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
        recognizeTextButton.isHidden = true
    }

    private func setupRecognizeTextButton() {
        contentView.addSubview(recognizeTextButton)
        recognizeTextButton.translatesAutoresizingMaskIntoConstraints = false
        recognizeTextButtonBottomConstraint = recognizeTextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        NSLayoutConstraint.activate([
            recognizeTextButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            recognizeTextButtonBottomConstraint!
        ])

        recognizeTextButton.addTarget(self, action: #selector(recognizeTextButtonTapped), for: .touchUpInside)
    }
    
    func setObject(object: Item) {
        removeCurrentTextSelectionInteraction()

        if isNeedToUpdateWebView, object.uuid == currentItemId {
            return
        }
        
        isNeedToUpdateWebView = false
        
        currentItemId = object.uuid
        fileType = object.fileType
        isLocalItem = object.isLocalItem
        placeholderImageView.isHidden = true
        recognizeTextButton.isHidden = true
        
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

    func setRecognizeTextButtonBottomSpacing(_ spacing: CGFloat) {
        recognizeTextButtonBottomConstraint?.constant = -spacing
        recognizeTextButton.setNeedsLayout()
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration) {
            self.layoutIfNeeded()
        }
    }

    func addTextSelectionInteraction(_ data: ImageTextSelectionData) {
        removeCurrentTextSelectionInteraction()

        let interaction = ImageTextSelectionInteraction(data: data)
        interaction.gesturesToIgnore = [tapGesture, imageScrollView.doubleTapGesture]
        imageScrollView.imageView.addInteraction(interaction)

        recognizeTextButton.isSelected = true

        currentTextSelectionInteraction = interaction
    }

    func removeCurrentTextSelectionInteraction() {
        if let currentTextSelectionInteraction = currentTextSelectionInteraction {
            imageScrollView.imageView.removeInteraction(currentTextSelectionInteraction)
            recognizeTextButton.isSelected = false
        }
    }
    
    @objc private func actionFullscreenTapGesture(_ gesture: UITapGestureRecognizer) {
        delegate?.tapOnCellForFullScreen()
    }
    
    @IBAction private func onPlayVideoButton() {
        delegate?.tapOnSelectedItem()
    }

    @objc private func recognizeTextButtonTapped() {
        guard let image = imageScrollView.imageView.image else {
            assertionFailure("image should be loaded")
            return
        }

        delegate?.recognizeTextButtonTapped(image: image, isActive: recognizeTextButton.isSelected)
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
            recognizeTextButton.isHidden = true
            setPlaceholder()
        } else {
            placeholderImageView.isHidden = true
            imageScrollView.isHidden = !(fileType == .video || fileType == .image)
            recognizeTextButton.isHidden = fileType != .image || isLocalItem || !isRecognizeTextEnabled
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
