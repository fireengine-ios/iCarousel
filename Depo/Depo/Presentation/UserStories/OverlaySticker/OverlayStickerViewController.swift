//
//  OverlayStickerViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Photos

final class OverlayStickerViewController: ViewController {
    
    private struct Attachment {
        let image: UIImage
        let url: URL
    }
    
    @IBOutlet private weak var overlayingStickerImageView: OverlayStickerImageView!
    @IBOutlet private weak var gifButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private var overlayStickerViewControllerDesigner: OverlayStickerViewControllerDesigner!
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    
    private let uploadService = UploadService()
    
    private lazy var applyButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "applyIcon"), for: .normal)
        button.addTarget(self, action: #selector(applyIconTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "removeCircle"), for: .normal)
        button.addTarget(self, action: #selector(closeIconTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    var selectedImage: UIImage?
    var imageName: String?
    
    private var pictureAttachment = [Attachment]()
    private var gifAttachment = [Attachment]()
    
    private var selectedAttachmentType: AttachedEntityType = .gif {
        willSet {
            switch newValue {
            case .gif:
                self.gifButton.tintColor = UIColor.yellow
                self.gifButton.setTitleColor(UIColor.yellow, for: .normal)
                self.stickerButton.tintColor = UIColor.gray
                self.stickerButton.setTitleColor(UIColor.gray, for: .normal)
                //TODO: Logic for updating collection view after changing selectedAttachmentType
                stickersCollectionView.reloadData()
            case .image:
                self.stickerButton.tintColor = UIColor.yellow
                self.stickerButton.setTitleColor(UIColor.yellow, for: .normal)
                self.gifButton.tintColor = UIColor.gray
                self.gifButton.setTitleColor(UIColor.gray, for: .normal)
                //TODO: Logic for updating collection view after changing selectedAttachmentType
                stickersCollectionView.reloadData()
            case .video:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedAttachmentType = .gif
        setupImage()
        stickersCollectionView.delegate = self
        stickersCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        // TODO: Temporary logic for trial mode
        addPictures()
        addGifs()
    }
    
    @IBAction private func gifButtonTapped(_ sender: Any) {
        selectedAttachmentType = .gif
    }
    
    @IBAction private func stickerButton(_ sender: Any) {
        selectedAttachmentType = .image
    }
    
    @IBAction private func undoButtonTapped(_ sender: Any) {
        overlayingStickerImageView.removeLast()
    }
    
    @objc func applyIconTapped() {
        
        showFullscreenHUD(with: nil, and: {})
        
        overlayingStickerImageView.getResult(resultName: imageName ?? UUID().uuidString) { [weak self] result in
            
            let popUp = PopUpController.with(title: TextConstants.save, message: TextConstants.smashPopUpMessage, image: .error, firstButtonTitle: TextConstants.cancel, secondButtonTitle: TextConstants.ok, firstUrl: nil, secondUrl: nil, firstAction: { popup in
                popup.close()
            }) { popup in
                popup.close()
                self?.showFullscreenHUD(with: nil, and: {})
                self?.saveResult(result: result)
            }
            self?.hideSpinnerIncludeNavigationBar()
            UIApplication.topController()?.present(popUp, animated: true, completion: nil)
        }
    }
    
    private func saveResult(result: CreateOverlayStickersResult) {
        
        checkLibraryAccessStatus { [weak self] libraryIsAvailable in
            
            if libraryIsAvailable == true {
                
                switch result {
                case .success(let result):
                    switch result.type {
                    case .gif: break
                    case .image:
                        //TODO: Different logic for saving result
                        self?.saveImageToLibrary(url: result.url) { isSavedInLibrary in
                        }
                        self?.uploadImage(contentURL: result.url, completion: { isUploaded in
                            self?.hideSpinnerIncludeNavigationBar()
                            self?.closeIconTapped()
                        })
        
                    case .video:
                        self?.saveVideoToLibrary(url: result.url) { isSavedInLibrary in }
                        self?.uploadVideo(contentURL: result.url, completion: { isUploaded in
                            self?.hideSpinnerIncludeNavigationBar()
                            self?.closeIconTapped()
                        })
                    }
                    
                case .failure(let error):
                    self?.hideSpinnerIncludeNavigationBar()
                    UIApplication.showErrorAlert(message: error.description)
                }
            } else {
                //Show popup about getting access to photo library
                self?.hideSpinnerIncludeNavigationBar()
            }
        }
    }
    
    @objc func closeIconTapped() {
        DispatchQueue.toMain {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupImage() {
        guard let selectedImage = selectedImage else {
            assertionFailure()
            return
        }
        overlayingStickerImageView.image = selectedImage
    }
    
    private func setupNavigationBar() {
        title = TextConstants.smashScreenTitle
        navigationBarWithGradientStyle()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = applyButton
    }
    
    private func uploadVideo(contentURL: URL, completion: @escaping (Bool) -> Void) {
        
        guard let videoData = try? Data(contentsOf: contentURL) else {
            completion(false)
            return
        }
        
        let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
        let item = WrapData(videoData: videoData)
        item.patchToPreview = PathForItem.remoteUrl(url)
        
        uploadService.uploadFileList(items: [item],
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(true) },
                                     fail: { errorResponce in
                                        completion(false) },
                                     returnedUploadOperation: {_ in })
    }
    
    private func uploadImage(contentURL: URL, completion: @escaping (Bool) -> Void) {
        
        guard let imageData = try? Data(contentsOf: contentURL) else {
            completion(false)
            return
        }
        
        let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
        let item = WrapData(imageData: imageData)
        item.patchToPreview = PathForItem.remoteUrl(url)
        
        uploadService.uploadFileList(items: [item],
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(true) },
                                     fail: { errorResponce in
                                        completion(false) },
                                     returnedUploadOperation: {_ in })
    }
    
    private func saveVideoToLibrary(url: URL, completion: @escaping (Bool) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func saveImageToLibrary(url: URL, completion: @escaping (Bool) -> ()) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }) { saved, error in
            if saved {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func checkLibraryAccessStatus(completion: @escaping (Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            completion(true)
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
}

extension OverlayStickerViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAttachmentType == .gif ? gifAttachment.count : pictureAttachment.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: StickerCollectionViewCell.self, for: indexPath)
    }
}

extension OverlayStickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? StickerCollectionViewCell else {
            return
        }
        
        let image = selectedAttachmentType == .gif ? gifAttachment[indexPath.row].image : pictureAttachment[indexPath.row].image
        
        cell.setupImageView(previewImage: image)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let url = selectedAttachmentType == .gif ? gifAttachment[indexPath.row].url : pictureAttachment[indexPath.row].url
        
        overlayingStickerImageView.addAttachment(url: url, attachmentType: selectedAttachmentType)
    }
}

//Temporary extension for trial period
extension OverlayStickerViewController {
    
    func addPictures() {
        guard let url = Bundle.main.url(forResource: "picture", withExtension: "png"), let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) else {
                   assertionFailure()
                   return
        }
        
        let attacment = Attachment(image: image, url: url)
        pictureAttachment = Array.init(repeating: attacment, count: 15)
    }
    
    func addGifs() {
        let examples = ["burn", "drone", "el", "kedi", "uyku"]
        examples.forEach({ createGifArray(name: $0) })
    }
    
    func createGifArray(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"), let imageData = try? Data(contentsOf: url), let gif = GIF(data: imageData), let numberOfFrames = gif.frames  else {
            assertionFailure()
            return
        }
        
        let middleIndex = numberOfFrames.count / 2
        guard let cgImage = gif.getFrame(at: middleIndex) else {
            assertionFailure()
            return
        }
        let image = UIImage(cgImage: cgImage)
        let attacment = Attachment(image: image, url: url)
        gifAttachment.append(attacment)
    }
}
