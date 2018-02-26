//
//  ShareViewController.swift
//  LifeboxShare
//
//  Created by Bondar Yaroslav on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import Social
import Alamofire

let factory: SharedFactory = FactoryBase()

final class ShareCustomizator: NSObject {
//    @IBOutlet private weak var cancelButton: UIButton! {
//        didSet {
//            cancelButton.isExclusiveTouch = true
//            cancelButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
//            cancelButton.setTitle("", for: .normal)
//            cancelButton.setTitleColor(ColorConstants.lightText, for: .normal)
//            cancelButton.setTitleColor(ColorConstants.darkText, for: .highlighted)
//        }
//    }
//    @IBOutlet private weak var uploadButton: UIButton! {
//        didSet {
//            uploadButton.isExclusiveTouch = true
//            uploadButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
//            uploadButton.setTitleColor(ColorConstants.blueColor, for: .normal)
//            uploadButton.setTitleColor(ColorConstants.blueColor.darker(), for: .highlighted)
//        }
//    }
//    @IBOutlet private weak var lineView: UIView! {
//        didSet {
//            lineView.backgroundColor = ColorConstants.blueColor
//        }
//    }
}

//final class ShareConfigurator {
//    
//    func setup() {
//        let urls: AuthorizationURLs = AuthorizationURLsImp()
//        let tokenStorage: TokenStorage = factory.resolve()
//        
//        var auth: AuthorizationRepository = AuthorizationRepositoryImp(urls: urls, tokenStorage: tokenStorage)
//        auth.refreshFailedHandler = { [weak self] in
////            self?.dismiss(animated: true, completion: nil)
//        }
//        
//        let sessionManager = SessionManager.default
//        sessionManager.retrier = auth
//        sessionManager.adapter = auth
//    }
//}

import MobileCoreServices

open class ShareData {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

final class ShareImage: ShareData {
    
}
final class ShareVideo: ShareData {
    
}


//SLComposeServiceViewController
final class ShareViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func actionCancelButton(_ sender: UIButton) {
        animateDismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = ColorConstants.searchShadowColor
        
        getSharedItems { sharedItems in
            print(sharedItems)
            print()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateAppear()
    }
    
    private func animateAppear() {
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func animateDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
        }, completion: { _ in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    //    override func isContentValid() -> Bool {
    //        // Do validation of contentText and/or NSExtensionContext attachments here
    //        return true
    //    }
    //
    //    override func didSelectPost() {
    //        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    //    
    //        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    //    }
    //
    //    override func configurationItems() -> [Any]! {
    //        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    //        return []
    //    }
    
}

extension ShareViewController {
    func getSharedItems(handler: @escaping ([ShareData]) -> Void) {
        guard
            let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachments = inputItem.attachments as? [NSItemProvider]
        else {
            return
        }
        
        var shareItems: [ShareData] = []
        let group = DispatchGroup()
        
        attachmentsFor: for itemProvider in attachments {
            
            let imageType = kUTTypeImage as String
            let pdfType = kUTTypePDF as String
            
            /// IMAGE
            if itemProvider.hasItemConformingToTypeIdentifier(imageType) {
                
                group.enter()
                itemProvider.loadItem(forTypeIdentifier: imageType, options: nil) { (item, error) in
                    guard let path = item as? URL else {
                        group.leave()
                        return
                    }
                    shareItems.append(ShareImage(url: path))
                    group.leave()
                }
                
                /// DATA 1
            } else if itemProvider.hasItemConformingToTypeIdentifier(pdfType) {
                
                group.enter()
                itemProvider.loadItem(forTypeIdentifier: pdfType, options: nil) { (item, error) in
                    guard let path = item as? URL else {
                        group.leave()
                        return
                    }
                    shareItems.append(ShareData(url: path))
                    group.leave()
                }
                
            } else {
                
                /// VIDEO
                let videoTypes = [kUTTypeMovie, kUTTypeVideo, kUTTypeMPEG, kUTTypeMPEG4, kUTTypeAVIMovie, kUTTypeQuickTimeMovie] as [String]
                
                for type in videoTypes {
                    if itemProvider.hasItemConformingToTypeIdentifier(type) {
                        
                        group.enter()
                        itemProvider.loadItem(forTypeIdentifier: type, options: nil) { (item, error) in
                            guard let path = item as? URL else {
                                group.leave()
                                return
                            }
                            shareItems.append(ShareVideo(url: path))
                            group.leave()
                        }
                        
                        /// we found video type. parse next itemProvider
                        continue attachmentsFor
                    }
                }
                
                /// if not any type try to take data
                /// DATA 2
                let dataType = "public.data"
                
                if itemProvider.hasItemConformingToTypeIdentifier(dataType) {
                    
                    group.enter()
                    itemProvider.loadItem(forTypeIdentifier: dataType, options: nil) { (item, error) in
                        guard let path = item as? URL else {
                            group.leave()
                            return
                        }
                        shareItems.append(ShareData(url: path))
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            handler(shareItems)
        }
    }
}
