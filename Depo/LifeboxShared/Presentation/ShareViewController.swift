//
//  ShareViewController.swift
//  LifeboxShare
//
//  Created by Bondar Yaroslav on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import MobileCoreServices

/// example of types in Info.plist
//
//<key>NSExtensionAttributes</key>
//<dict>
//<key>NSExtensionActivationRule</key>
//<dict>
//<key>NSExtensionActivationSupportsFileWithMaxCount</key>
//<integer>100</integer>
//<key>NSExtensionActivationSupportsImageWithMaxCount</key>
//<integer>100</integer>
//<key>NSExtensionActivationSupportsMovieWithMaxCount</key>
//<integer>100</integer>
//</dict>
//</dict>

/// customize types for share extension
/// https://pspdfkit.com/blog/2016/hiding-action-share-extensions-in-your-own-apps/
/// https://stackoverflow.com/questions/46826806/ios-11-pdf-share-extension

final class ShareViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var currentPhotoImageView: UIImageView!
    @IBOutlet private weak var currentNameLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var uploadProgress: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    private let shareConfigurator = ShareConfigurator()
    private var sharedItems = [ShareData]()
    
    lazy var uploadService = UploadQueueService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSharedItems()
        shareConfigurator.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAppear()
    }
    
    @IBAction private func actionCancelButton(_ sender: UIButton) {
        uploadService.cancelAll()
        animateDismiss()
    }
    
    @IBAction private func actionUploadButton(_ sender: UIButton) {
        progressLabel.text = L10n.uploading
        
        sender.isEnabled = false
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.uploadService.addShareData(self.sharedItems, progress: { [weak self] progress in
                DispatchQueue.main.async {
                    self?.uploadProgress.progress = Float(progress.fractionCompleted)
                }
            }, didStartUpload: { shareData in
                DispatchQueue.main.async {
                    self.updateCurrentUI(for: shareData)
                }
            }, complition: { [weak self] result in
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    switch result {
                    case .success(_):
                        self?.animateDismiss()
                    case .failed(let error):
                        self?.progressLabel.text = error.parsedDescription
                    }
                }
            })
        }

    }
    
    private func setupSharedItems() {
        DispatchQueue.global().async {
            self.getSharedItems { sharedItems in
                self.sharedItems = sharedItems
                
                DispatchQueue.main.async {
                    if let shareData = sharedItems.first {
                        self.updateCurrentUI(for: shareData)
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func updateCurrentUI(for shareData: ShareData) {
        currentNameLabel.text = shareData.name
        currentPhotoImageView.image = shareData.image
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
}

// MARK: - UICollectionViewDataSource
extension ShareViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sharedItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ImageColCell.self, for: indexPath)
        let image = sharedItems[indexPath.row].image
        cell.setImage(image)
        return cell
    }
}

// MARK: - SharedItems
extension ShareViewController {
    func getSharedItems(handler: @escaping ([ShareData]) -> Void) {
        
        guard
            let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachments = inputItem.attachments as? [NSItemProvider]
        else {
            return
        }
        
        /// type constatnts
        let imageType = kUTTypeImage as String
        let pdfType = kUTTypePDF as String
        let dataType = "public.data"
        let videoTypes = [kUTTypeMovie,
                          kUTTypeVideo,
                          kUTTypeMPEG,
                          kUTTypeMPEG4,
                          kUTTypeAVIMovie,
                          kUTTypeQuickTimeMovie] as [String]
        
        var shareItems: [ShareData] = []
        let group = DispatchGroup()
        
        attachmentsFor: for itemProvider in attachments {
            
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
