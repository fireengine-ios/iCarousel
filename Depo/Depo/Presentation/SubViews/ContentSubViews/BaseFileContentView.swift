//
//  BaseFileContentView.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BaseFileContentViewDelegate: class {
    func tapOnSelectedItem()
    
    func pageToRight()
    func pageToLeft()
}

class BaseFileContentView: UIView {
    
    weak var delegate: BaseFileContentViewDelegate?
    var index: Int = -1

    @IBOutlet weak var imageView: LoadingImageView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var playVideoButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!

    
    class func initFromXib() -> BaseFileContentView {
        let view = UINib(nibName: "BaseFileContentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BaseFileContentView
        view.configurateView()
        return view
    }
    
    func configurateView(){
        self.backgroundColor = UIColor.clear
    }
    
    func setObject(object:Item, index: Int) {
        webView.isHidden = true
//        webView.scrollView.bounces = false
        
        imageView.image = nil
        playVideoButton.isHidden = true
        self.index = index
        
        if object.fileType == .video || object.fileType == .image {
            imageView.loadImage(with: object, isOriginalImage: true)
            playVideoButton.isHidden = !(object.fileType == FileType.video)
        } else if object.fileType != .audio {
            if object.fileType.isUnSupportedOpenType {
                imageView.isHidden = true
                webView.isHidden = false
                if let url = object.urlToFile {
                    webView.delegate = self
                    webView.loadRequest(URLRequest(url: url))
                }
            }
        }
    }
    
    @IBAction func onPlayVideoButton() {
        if (delegate != nil){
            delegate?.tapOnSelectedItem()
        }
    }
    
}

extension BaseFileContentView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if webView.isHidden {
            return
        }
        let scrollWidth = webView.scrollView.frame.size.width
        let scrollOffsetX = webView.scrollView.contentOffset.x
        
        if scrollWidth + scrollOffsetX > webView.scrollView.contentSize.width + scrollWidth * 0.15 {
            delegate?.pageToRight()
        } else if scrollOffsetX < 0 - scrollWidth * 0.15 {
            delegate?.pageToLeft()
        }
        
    }
}

extension BaseFileContentView: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.scrollView.delegate = self
    }
}
