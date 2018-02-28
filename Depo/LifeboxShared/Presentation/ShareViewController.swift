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

import Alamofire

enum URLs {
    static let uploadContainer = RouteRequests.BaseUrl +/ "/api/container/baseUrl"
}

extension URL {
    var imageContentType: String {
        let type = pathExtension.lowercased()
        
        if !type.isEmpty {
            return "image/\(type)"
        } else if let data = try? Data(contentsOf: self) {
            return ImageFormat.get(from: data).contentType
        } else {
            return "image/jpg" 
        }
    }
}

final class UploadService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
    }
    
    func getBaseUploadUrl(handler: @escaping ResponseHandler<String>) {
        sessionManager
            .request(URLs.uploadContainer)
            .customValidate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: String], let path = json["value"] {
                        handler(ResponseResult.success(path))
                    } else {
                        let error = CustomErrors.text("Server error \(json)")
                        handler(ResponseResult.failed(error))
                    }
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
    
    func upload(url: URL, progressHandler: @escaping Request.ProgressHandler, complition: @escaping ResponseVoid) {
        
        getBaseUploadUrl { result in
            switch result {
            case .success(let path):
                guard let serverUrl = URL(string: path) else {
                    return
                }
                let uploadUrl = serverUrl +/ UUID().uuidString
                
                let headers: HTTPHeaders = [
                    HeaderConstant.XObjectMetaFavorites: "false",
                    HeaderConstant.XMetaStrategy: "1",
                    HeaderConstant.Expect: "100-continue",
                    HeaderConstant.XObjectMetaParentUuid: "",
                    HeaderConstant.XObjectMetaFileName: url.lastPathComponent,
                    HeaderConstant.ContentType: url.imageContentType,
                    HeaderConstant.XObjectMetaSpecialFolder: "MOBILE_UPLOAD"
                ]
                
                self.sessionManager
                    .upload(url, to: uploadUrl, method: .put, headers: headers)
                    .customValidate()
                    .uploadProgress(closure: progressHandler)
                    .responseString { response in
                        switch response.result {
                        case .success(_):
                            complition(ResponseResult.success(()))
                        case .failure(let error):
                            complition(ResponseResult.failed(error))
                        }
                }
                
            case .failed(let error):
                complition(ResponseResult.failed(error))
            }
        }
        

    }
}

final class ShareViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var currentPhotoImageView: UIImageView!
    @IBOutlet private weak var currentNameLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var uploadProgress: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    private let shareConfigurator = ShareConfigurator()
    private var sharedItems = [ShareData]()
    
    lazy var uploadService = UploadService()
    
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
        animateDismiss()
    }
    
    @IBAction private func actionUploadButton(_ sender: UIButton) {
        progressLabel.text = "Uploading..."
        let url = sharedItems.first!.url
        
        uploadService.upload(url: url, progressHandler: { [weak self] progress in
            self?.uploadProgress.progress = Float(progress.fractionCompleted)
        }, complition: { [weak self] result in
            switch result {
            case .success(_):
                self?.animateDismiss()
            case .failed(let error):
                self?.progressLabel.text = error.localizedDescription
            }
        })
    }
    
    private func setupSharedItems() {
        DispatchQueue.global().async {
            self.getSharedItems { sharedItems in
                self.sharedItems = sharedItems
                
                DispatchQueue.main.async {
                    self.currentNameLabel.text = sharedItems.first?.name
                    self.currentPhotoImageView.image = sharedItems.first?.image
                    self.collectionView.reloadData()
                }
            }
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
