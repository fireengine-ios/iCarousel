//
//  OverlayStickerViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class OverlayStickerViewController: ViewController {
    
    private struct Attachment {
        let image: UIImage
        let url: URL
    }
    
    @IBOutlet private weak var overlayingStickerImageView: OverlayStickerImageView!
    @IBOutlet private weak var gifButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private var OverlayStickerViewControllerDesigner: OverlayStickerViewControllerDesigner!
    
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    
    private lazy var applyButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "applyIcon"), for: .normal)
        button.addTarget(self, action: #selector(applyIconTapped(sender:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "removeCircle"), for: .normal)
        button.addTarget(self, action: #selector(closeIconTapped(sender:)), for: .touchUpInside)
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
                stickersCollectionView.reloadData()
            case .image:
                self.stickerButton.tintColor = UIColor.yellow
                self.stickerButton.setTitleColor(UIColor.yellow, for: .normal)
                self.gifButton.tintColor = UIColor.gray
                self.gifButton.setTitleColor(UIColor.gray, for: .normal)
                stickersCollectionView.reloadData()
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
    
    @objc func applyIconTapped(sender: UIButton) {
        self.showSpinner()
        overlayingStickerImageView.getResult(resultName: imageName ?? "pictureWitImage") { [weak self] result in
            switch result {
            case .success(_):
                self?.hideSpinner()
            case .failure(let error):
                self?.hideSpinner()
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    @objc func closeIconTapped(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupImage() {
        guard let selectedImage = selectedImage else {
            assertionFailure()
            return
        }
        overlayingStickerImageView.image = selectedImage
    }
    
    func setupNavigationBar() {
        title = TextConstants.smashScreenTitle
        navigationBarWithGradientStyle()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = applyButton
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
        
        cell.setupImgeViewImage(previewImage: image)
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
