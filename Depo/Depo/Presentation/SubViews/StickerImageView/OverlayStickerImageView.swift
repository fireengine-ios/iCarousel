//
//  SmashStickerView.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import YYImage
import ImageIO

enum AttachedEntityType {
    case gif
    case image
}

enum CreateOverlayResultType {
    case image
    case video
}

struct CreateOverlayStickersSuccessResult {
    let url: URL
    let type: CreateOverlayResultType
}

typealias CreateOverlayStickersResult = Result<CreateOverlayStickersSuccessResult, CreateOverlayStickerError>

protocol OverlayStickerImageViewdelegate {
    func makeTopAndBottomBarsIsHidden(isHidden: Bool)
}

final class OverlayStickerImageView: UIImageView {
    
    private var attachments: [UIImageView] = []
    private var mainSticker: UIImageView?
    
    private let panGesture = UIPanGestureRecognizer()
    private let pinchGesture = UIPinchGestureRecognizer()
    private let rotationGesture = UIRotationGestureRecognizer()
    
    private var startPositionSelectedView: CGPoint?
    private var startSizeSelectedView: CGSize?
    private var startRotatePosition: CGFloat?
    private var selectedSticker: UIImageView?
    var stickersDelegate: OverlayStickerImageViewdelegate?
    
    private let stickerSize = CGSize(width: 50, height: 50)
    private lazy var overlayAnimationService = OverlayAnimationService()
    private let downloader = ImageDownloder()
    
    private let trashBinLayer: CALayer = {
        let trashBinLayer = CALayer()
        let binImage = UIImage(named: "trash")?.cgImage
        trashBinLayer.contents = binImage
        trashBinLayer.isHidden = true
        return trashBinLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
        isUserInteractionEnabled = true
        self.backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizers()
        isUserInteractionEnabled = true
        self.backgroundColor = .black
    }
    
    func addAttachment(url: URL, attachmentType: AttachedEntityType, completion: @escaping VoidHandler) {
        stopAnimateStickers()
        attachmentType == .gif ? createGifAttachment(url: url, completion: completion) : createImageAttachment(url: url, completion: completion)
    }
    
    func removeLast() {
        guard !attachments.isEmpty else {
            return
        }
        
        let subview = attachments.removeLast()
        subview.removeFromSuperview()
    }
    
    func overlayStickers(resultName: String, completion: @escaping (CreateOverlayStickersResult) -> () ) {
            stopAnimateStickers()
        
            if self.subviews.contains(where: { $0 is YYAnimatedImageView}) {
                self.subviews.forEach({ $0.isHidden = true})
                
                guard let img = UIImage.imageWithView(view: self) else {
                    return completion(.failure(.unknown))
                }
                
                self.subviews.forEach({ $0.isHidden = false})
                
                self.overlayAnimationService.combine(attachments: self.attachments, resultName: resultName, originalImage: img) { [weak self] createStickerResult in
                    completion(createStickerResult)
                    self?.restartAnimateStickers()
                }
            } else {
                
                guard let sticker = UIImage.imageWithView(view: self) else {
                    completion(.failure(.unknown))
                    return
                }
                
                self.saveImage(image: sticker, fileName: resultName, completion: completion)
                restartAnimateStickers()
            }
    }
    
    private func saveImage(image: UIImage, fileName: String, completion: (CreateOverlayStickersResult) -> ()) {
        guard let data = image.jpeg(.highest) ?? UIImagePNGRepresentation(image)  else {
            completion(.failure(.unknown))
            return
        }
        
        let format = ImageFormat.get(from: data) == .jpg ? ".jpg" : ".png"
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            completion(.failure(.unknown))
            return
        }
        
        do {
            guard let path = directory.appendingPathComponent(fileName + format) else {
                assertionFailure()
                completion(.failure(.unknown))
                return
            }
            try data.write(to: path)
            completion(.success(CreateOverlayStickersSuccessResult(url: path, type: .image)))
        } catch {
            completion(.failure(.unknown))
        }
    }
    
    private func createGifAttachment(url: URL, completion: @escaping VoidHandler) {
        setupTrasBinFrame()
        
        downloader.getImageData(url: url) { [weak self] data in
            
            guard
                let self = self,
                let imageData = data,
                let image = YYImage(data: imageData)
            else {
                return
            }
            
            DispatchQueue.toMain {
                
                let imageView = YYAnimatedImageView(image: image)
            
                imageView.frame.size = CGSize(width: UIScreen.main.bounds.width * 0.4,
                                              height: UIScreen.main.bounds.width * 0.4)
                
                imageView.center = self.center
                self.addSubview(imageView)
                self.attachments.append(imageView)
                self.restartAnimateStickers()
                completion()
            }
        }
    }
    
    private func createImageAttachment(url: URL, completion: @escaping VoidHandler) {
        setupTrasBinFrame()
    
        downloader.getImageData(url: url) { [weak self] data in
            
            guard
                let self = self,
                let imageData = data,
                let image = UIImage(data: imageData)
            else {
                return
            }
            
            DispatchQueue.toMain {
                let imageView = UIImageView(image: image)
                imageView.center = self.center
                imageView.frame.size = CGSize(width: UIScreen.main.bounds.width * 0.4,
                                              height: UIScreen.main.bounds.width * 0.4)
                
                self.addSubview(imageView)
                self.attachments.append(imageView)
                self.restartAnimateStickers()
                completion()
            }
        }
    }
    
    func setupTrasBinFrame() {
        let trashBinOrigin = CGPoint(x: UIScreen.main.bounds.width / 2 - (self.stickerSize.width / 2),
                                     y: self.frame.height - self.stickerSize.height - 20)
        trashBinLayer.frame = CGRect(origin: trashBinOrigin, size: self.stickerSize)
        self.layer.addSublayer(trashBinLayer)
    }
    
    @objc private func handlePan(_ pan:UIPanGestureRecognizer) {
        
        let point = pan.location(in: self)
        let translation = pan.translation(in: self)
        
        switch pan.state {
        case .began:
            
            guard let subview = self.subviews.filter({$0.frame.contains(point)}).last as? UIImageView else {
                hideTrashBin()
                return
            }
            
            startPositionSelectedView = subview.center
            selectedSticker = subview
            if subview != mainSticker {
                self.bringSubview(toFront: subview)
            }
            
        case .changed:
            guard let startPosition = startPositionSelectedView, let selectedSticker = selectedSticker, selectedSticker != mainSticker else {
                hideTrashBin()
                return
            }
            showTrashBin()
            
            
            selectedSticker.center = CGPoint(x: startPosition.x + translation.x, y: startPosition.y + translation.y)
            
        case .ended, .cancelled, .failed, .possible:
            
            guard let selectedSticker = selectedSticker, selectedSticker != mainSticker else {
                hideTrashBin()
                return
            }
            
            startPositionSelectedView = selectedSticker.center
            
            if trashBinLayer.frame.contains(selectedSticker.center) {
                attachments = attachments.filter({ $0 !== selectedSticker })
                
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: {
                    selectedSticker.alpha = 0
                }) { _ in
                    selectedSticker.removeFromSuperview()
                }
            }
            
            self.selectedSticker = nil
            hideTrashBin()
        }
    }
    
    
    @objc private func handlePich(_ pinch:UIPinchGestureRecognizer) {
        
        let point = pinch.location(in: self)
        
        guard let subview = self.subviews.filter({$0.frame.contains(point)}).last, subview != mainSticker else {
            hideTrashBin()
            return
        }
        
        switch pinch.state {
            
        case .began:
            startSizeSelectedView = subview.bounds.size
        case .changed:
            guard let selectedViewSize = startSizeSelectedView, selectedSticker != mainSticker else {
                hideTrashBin()
                return
            }
            showTrashBin()
            let ratio = selectedViewSize.width / selectedViewSize.height
            let height = selectedViewSize.height * pinch.scale
            
            subview.bounds.size = CGSize(width: height * ratio, height: height)
            
        case .ended, .possible, .cancelled, .failed:
            self.selectedSticker = nil
            hideTrashBin()
        }
    }
    
    @objc private func handleRotate(_ rotate:UIRotationGestureRecognizer) {
        
        let point = rotate.location(in: self)
        
        guard let subview = self.subviews.filter({$0.frame.contains(point)}).last, subview != mainSticker else {
            hideTrashBin()
            return
        }
        
        switch rotate.state {
        case .began:
            startRotatePosition = rotate.rotation
        case .changed:
            guard let selectedViewRotation = startRotatePosition, selectedSticker != mainSticker else {
                hideTrashBin()
                return
            }
            showTrashBin()
            subview.transform = subview.transform.rotated(by: rotate.rotation - selectedViewRotation)
            startRotatePosition = atan2(subview.transform.b, subview.transform.a)
            
        case .ended, .possible, .cancelled, .failed:
            self.selectedSticker = nil
            hideTrashBin()
        }
    }
    
    private func hideTrashBin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.stickersDelegate?.makeTopAndBottomBarsIsHidden(isHidden: false)
            self.trashBinLayer.isHidden = true
        }
    }
    
    private func showTrashBin() {
        stickersDelegate?.makeTopAndBottomBarsIsHidden(isHidden: true)
        trashBinLayer.isHidden = false
    }
    
    private func restartAnimateStickers() {
        attachments.forEach({ item in
            if let newItem = item as? YYAnimatedImageView {
                newItem.currentAnimatedImageIndex = 0
                newItem.startAnimating()
            }
        })
    }
    
    private func stopAnimateStickers() {
        attachments.forEach({ item in
            if let newItem = item as? YYAnimatedImageView {
                newItem.stopAnimating()
            }
        })
    }
    
    private func setupGestureRecognizers() {
        panGesture.addTarget(self, action: #selector(self.handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        pinchGesture.addTarget(self, action: #selector(handlePich(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        rotationGesture.addTarget(self, action: #selector(handleRotate(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
    }
    
    private func isRaisedMovement(previousPosition: CGFloat, newPosition: CGFloat) -> Bool {
        return previousPosition > newPosition ? false : true
    }
    
    private func getMaxStickerSide() -> CGFloat {
        if self.frame.width > self.frame.height {
            return self.frame.height / 2
        } else if self.frame.width < self.frame.height  {
            return self.frame.width / 2
        } else {
            return self.frame.height / 2
        }
    }
}

extension OverlayStickerImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

