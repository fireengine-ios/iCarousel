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
    private lazy var shareWormholeListener = ShareWormholeListener()
    private var sharedItems = [SharedItemSource]()
    private var currentUploadIndex = -1
    
    private lazy var uploadService = UploadQueueService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSharedItems()
        shareConfigurator.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPasscodeIfNeed()
    }

    private func setupPasscodeIfNeed() {
        if shareConfigurator.isNeedToShowPasscode {
            shareWormholeListener.listenLogout { [weak self] in
                if let navVC = self?.navVC {
                    navVC.dismiss(animated: true) { 
                        self?.animateDismiss()
                    }
                } else {
                    self?.animateDismiss()
                }
            }
            showPasscode()
        }
    }
    
    private var navVC: UINavigationController?
    
    private func showPasscode() {
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        
        let navVC = UINavigationController(rootViewController: vc)
        self.navVC = navVC
        
        vc.success = {
            navVC.dismiss(animated: true, completion: nil)
        }
        
        present(navVC, animated: true, completion: nil)
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
        progressLabel.text = TextConstants.uploading
        
        sender.isEnabled = false
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.uploadService.addSharedItems(self.sharedItems, progress: { [weak self] progress in
                DispatchQueue.main.async {
                    self?.uploadProgress.progress = Float(progress.fractionCompleted)
                }
            }, didStartUpload: { [weak self] sharedItem in
                self?.updateCurrentUI(for: sharedItem)
                self?.updateCurrentUploadInCollectionView(with: sharedItem)
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
                    if let sharedItems = sharedItems.first {
                        self.updateCurrentUI(for: sharedItems)
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func updateCurrentUI(for sharedItem: SharedItemSource) {
        switch sharedItem {
        case .url(let item):
            self.currentNameLabel.text = item.name
            
            DispatchQueue.global().async { [weak self] in
                FilesExistManager.shared.waitFilePreparation(at: item.url) { [weak self] result in
                    guard let `self` = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.currentPhotoImageView.setScreenScaledImage(item.image)
                        case .failed(_):
                            self.currentPhotoImageView.image = Images.noDocuments
                        }
                        self.currentPhotoImageView.backgroundColor = UIColor.white
                    }
                }
            }
            
        case .data(let item):
            self.currentPhotoImageView.image = item.image
            self.currentNameLabel.text = item.name
        }
    }
    
    private func updateCurrentUploadInCollectionView(with sharedItem: SharedItemSource) {
        guard let index = sharedItems.index(of: sharedItem) else {
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
