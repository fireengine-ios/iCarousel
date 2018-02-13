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
    
    private lazy var filesDataSource = FilesDataSource()
    
//    @IBOutlet private weak var imageView: LoadingImageView!
    @IBOutlet private weak var imageScrollView: ImageScrollView!
    @IBOutlet private weak var activity: UIActivityIndicatorView!
    @IBOutlet private weak var playVideoButton: UIButton!
    @IBOutlet private weak var webView: UIWebView!
    
    private var index: Int = -1
    
    weak var delegate: PhotoVideoDetailCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageScrollView.updateZoom()
    }
    
    func setObject(object:Item, index: Int) {
        webView.isHidden = true
        
        imageScrollView.imageView.image = nil
        playVideoButton.isHidden = true
        self.index = index
        
        if object.fileType == .video || object.fileType == .image {
//            imageScrollView.imageView.loadImage(with: object, isOriginalImage: true)
            filesDataSource.getImage(for: object, isOriginal: true) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageScrollView.delegate = self
                    self?.imageScrollView.image = image
                    
//                    guard let image = image else { return }
                }
            }
            playVideoButton.isHidden = !(object.fileType == FileType.video)
            
        } else if object.fileType != .audio, object.fileType.isUnSupportedOpenType {
            imageScrollView.imageView.isHidden = true
            webView.isHidden = false
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if webView.isHidden {
//            return
//        }
//        let scrollWidth = webView.scrollView.frame.size.width
//        let scrollOffsetX = webView.scrollView.contentOffset.x
//        
//        if scrollWidth + scrollOffsetX > webView.scrollView.contentSize.width + scrollWidth * 0.15 {
//            delegate?.pageToRight()
//        } else if scrollOffsetX < 0 - scrollWidth * 0.15 {
//            delegate?.pageToLeft()
//        }
    }
    
    // MARK: - imageScrollView
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageScrollView.adjustFrameToCenter()
    }
}

extension PhotoVideoDetailCell: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.scrollView.delegate = self
    }
}
