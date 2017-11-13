//
//  BaseFileContentView.swift
//  Depo
//
//  Created by Oleg on 01.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BaseFileContentViewDeleGate{
    func tapOnSelectedItem()
}

class BaseFileContentView: UIView {
    
    typealias Item = WrapData
    
    var delegate:BaseFileContentViewDeleGate?
    var index: Int = -1

    @IBOutlet weak var imageView: LoadingImageView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var playVideoButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!

    
    class func initFromXib()->BaseFileContentView{
        let view = UINib(nibName: "BaseFileContentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BaseFileContentView
        view.configurateView()
        return view
    }
    
    func configurateView(){
        self.backgroundColor = UIColor.clear
    }
    
    func setObject(object:Item, index: Int) {
        webView.isHidden = true
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
                    self.webView.loadRequest(URLRequest(url: url))
                }
            }
        }
    }
    
    @IBAction func onPlayVideoButton(){
        if (delegate != nil){
            delegate?.tapOnSelectedItem()
        }
    }
    
}
