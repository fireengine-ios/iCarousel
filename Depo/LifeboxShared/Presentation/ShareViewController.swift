//
//  ShareViewController.swift
//  LifeboxShare
//
//  Created by Bondar Yaroslav on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

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

final class ShareViewController: UIViewController, ShareController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var currentPhotoImageView: UIImageView!
    @IBOutlet private weak var currentNameLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var uploadProgress: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    private let shareConfigurator = ShareConfigurator()
    private var sharedItems = [ShareData]()
    private var currentUploadIndex = -1
    
    private lazy var uploadService = UploadQueueService()
    
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
            }, didStartUpload: { [weak self] shareData in
                self?.updateCurrentUI(for: shareData)
                self?.updateCurrentUploadInCollectionView(with: shareData)
            }, complition: { [weak self] result in
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    switch result {
                    case .success(_):
                        self?.animateDismiss()
                    case .failed(let error):
                        self?.progressLabel.text = error.parsedDescription
                    }
                    
                    self?.currentUploadIndex = -1
                    //                self?.collectionView.performBatchUpdates(nil, completion: nil)
                    self?.collectionView.reloadData()
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
        DispatchQueue.global().async { [weak self] in
            FileManager.shared.waitFilePreparation(at: shareData.url) { [weak self] result in
                guard let `self` = self else {
                    return
                }
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self.currentPhotoImageView.setScreenScaledImage(shareData.image)
                    case .failed(_):
                        self.currentPhotoImageView.image = #imageLiteral(resourceName: "ImageNoDocuments")
                    }
                    self.currentPhotoImageView.backgroundColor = UIColor.white
                }
            }
        }
        DispatchQueue.main.async {
            self.currentNameLabel.text = shareData.name
        }
    }
    
    private func updateCurrentUploadInCollectionView(with shareData: ShareData) {
        guard let index = sharedItems.index(of: shareData) else {
            return
        }
        
        currentUploadIndex = index
        let currentCellIndex = IndexPath(row: index, section: 0)
        
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                if index > 0 {
                    let previusCellIndex = IndexPath(row: index - 1, section: 0)
                    self.collectionView.reloadItems(at: [previusCellIndex, currentCellIndex])
                } else {
                    self.collectionView.reloadItems(at: [currentCellIndex])
                }
            }, completion: { _ in
                self.collectionView.scrollToItem(at: currentCellIndex, at: .left, animated: true)
            })
        }

//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//            self.collectionView.scrollToItem(at: currentCellIndex, at: .left, animated: true)
//        }
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
        cell.setup(with: sharedItems[indexPath.row])
        cell.setup(isCurrentUploading: indexPath.row == currentUploadIndex)
        return cell
    }
}
