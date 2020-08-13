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
    
    var toPHMediaType: PHAssetMediaType {
        switch self {
        case .image:
            return .image
        case .video:
            return .video
        }
    }
}

struct CreateOverlayStickersSuccessResult {
    let url: URL
    let type: CreateOverlayResultType
}

typealias CreateOverlayStickersResult = Result<CreateOverlayStickersSuccessResult, CreateOverlayStickerError>

protocol OverlayStickerImageViewDelegate: class {
    func makeTopAndBottomBarsIsHidden(isHidden: Bool)
}

final class OverlayStickerImageView: UIImageView {
    
    private final class Attachment {
        let item: SmashStickerResponse
        let imageView: UIImageView
        
        init(item: SmashStickerResponse, imageView: UIImageView) {
            self.item = item
            self.imageView = imageView
        }
    }
    
    private var attachments: [Attachment] = []
    private var mainSticker: UIImageView?
    
    private let panGesture = UIPanGestureRecognizer()
    private let pinchGesture = UIPinchGestureRecognizer()
    private let rotationGesture = UIRotationGestureRecognizer()
    
    private var startPositionSelectedView: CGPoint?
    private var startSizeSelectedView: CGSize?
    private var startRotatePosition: CGFloat?
    private var selectedSticker: UIImageView?
    weak var stickersDelegate: OverlayStickerImageViewDelegate?
    
    private let stickerSize = CGSize(width: 50, height: 50)
    private let downloader = ImageDownloder()
    private lazy var impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
    private var isImpactOccurred: Bool =  false
    
    private let trashBinLayer: CALayer = {
        let trashBinLayer = CALayer()
        let binImage = UIImage(named: "trash")?.cgImage
        trashBinLayer.contents = binImage
        trashBinLayer.isHidden = true
        return trashBinLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    deinit {
        panGesture.delegate = nil
        pinchGesture.delegate = nil
        rotationGesture.delegate = nil
    }
    
    private func setupView() {
        setupGestureRecognizers()
        isUserInteractionEnabled = true
        backgroundColor = .black
    }
    
    func addAttachment(item: SmashStickerResponse, attachmentType: AttachedEntityType, completion: @escaping VoidHandler) {
        attachmentType == .gif ? createGifAttachment(item: item, completion: completion) : createImageAttachment(item: item, completion: completion)
    }
    
    func removeLast() {
        guard !attachments.isEmpty else {
            return
        }
        
        let subview = attachments.removeLast()
        subview.imageView.removeFromSuperview()
    }
    
    func getCondition() -> (originalImage: UIImage, attachments: [UIImageView])? {
        
        subviews.forEach({ $0.isHidden = true})

        guard let img = UIImage.imageWithView(view: self) else {
            return nil
        }
        
        subviews.forEach { $0.isHidden = false }
        let attachment = attachments.map { $0.imageView }
        return (img, attachment)
    }
    
    private func createGifAttachment(item: SmashStickerResponse, completion: @escaping VoidHandler) {
        setupTrasBinFrame()
        
        downloader.getImageData(url: item.path) { [weak self] data in
            
            guard let self = self, let imageData = data else {
                return
            }

            let img = OptimizingGifService().optimizeImage(data: imageData, optimizeFor: .sticker)
            
            DispatchQueue.toMain {
                
                let imageView = YYAnimatedImageView(image: img)
            
                imageView.frame.size = CGSize(width: UIScreen.main.bounds.width * 0.4,
                                              height: UIScreen.main.bounds.width * 0.4)
                
                imageView.center = self.center
                self.addSubview(imageView)
                let attachment = Attachment(item: item, imageView: imageView)
                self.attachments.append(attachment)
                completion()
            }
        }
    }
    
    private func createImageAttachment(item: SmashStickerResponse, completion: @escaping VoidHandler) {
        setupTrasBinFrame()
    
        downloader.getImageData(url: item.path) { [weak self] data in
            
            guard let self = self, let imageData = data, let image = UIImage(data: imageData) else {
                return
            }
            
            DispatchQueue.main.async {
                let imageView = UIImageView(image: image)
                
                imageView.frame.size = CGSize(width: UIScreen.main.bounds.width * 0.4,
                                              height: UIScreen.main.bounds.width * 0.4)
                imageView.center = self.center
                
                self.addSubview(imageView)
                let attachment = Attachment(item: item, imageView: imageView)
                self.attachments.append(attachment)
                completion()
            }
        }
    }
    
    func setupTrasBinFrame() {
        let trashBinOrigin = CGPoint(x: UIScreen.main.bounds.width / 2 - (self.stickerSize.width / 2),
                                     y: self.frame.height - self.stickerSize.height - 20)
        trashBinLayer.frame = CGRect(origin: trashBinOrigin, size: self.stickerSize)
        layer.addSublayer(trashBinLayer)
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
                bringSubview(toFront: subview)
            }
            
        case .changed:
            guard let startPosition = startPositionSelectedView, let selectedSticker = selectedSticker, selectedSticker != mainSticker else {
                hideTrashBin()
                return
            }
            showTrashBin()
            
            
            selectedSticker.center = CGPoint(x: startPosition.x + translation.x, y: startPosition.y + translation.y)
            
            if trashBinLayer.frame.contains(selectedSticker.center) {
                
                trashBinLayer.bounds.size = CGSize(width: stickerSize.width * 1.5, height: stickerSize.width * 1.5)
                
                if !isImpactOccurred { impactFeedbackgenerator.impactOccurred() }
                isImpactOccurred = true
            } else {
               isImpactOccurred = false
               setupTrasBinFrame()
            }
            
        case .ended, .cancelled, .failed, .possible:
            isImpactOccurred = false
            guard let selectedSticker = selectedSticker, selectedSticker != mainSticker else {
                hideTrashBin()
                return
            }
            
            startPositionSelectedView = selectedSticker.center
            
            if trashBinLayer.frame.contains(selectedSticker.center) {
                attachments = attachments.filter({ $0 !== selectedSticker })
                
                UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseIn, animations: {
                    selectedSticker.alpha = 0
                }) { [weak self] _ in
                    self?.attachments.removeAll(where: { $0.imageView === selectedSticker })
                    selectedSticker.removeFromSuperview()
                }
            }
            
            self.selectedSticker = nil
            hideTrashBin()
        }
    }
    
    
    @objc private func handlePich(_ pinch:UIPinchGestureRecognizer) {
        
        let point = pinch.location(in: self)
        
        guard let subview = subviews.filter({$0.frame.contains(point)}).last, subview != mainSticker else {
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
            selectedSticker = nil
            hideTrashBin()
        }
    }
    
    @objc private func handleRotate(_ rotate:UIRotationGestureRecognizer) {
        
        let point = rotate.location(in: self)
        
        guard let subview = subviews.filter({$0.frame.contains(point)}).last, subview != mainSticker else {
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
            selectedSticker = nil
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
    
    private func setupGestureRecognizers() {
        panGesture.addTarget(self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        pinchGesture.addTarget(self, action: #selector(handlePich(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
        rotationGesture.addTarget(self, action: #selector(handleRotate(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
    }
    
    func getAttachmentInfoForAnalytics() -> String {
        
        var message = ""
        let attach = attachments.map{ $0.item }
        let keys = Set(attach)
    
        keys.forEach({ key in
            var msg = ""
            let items = attach.filter({ $0 == key })
            msg.append("\(items.count)")
            if key.type == .gif {
                msg.append("G")
            } else{
                msg.append("S")
            }
            msg.append("\(key.id)")
            
            if keys.count > 1 {
                msg.append("|")
            }
            message.append(msg)
        })
        
        if message.last == "|" {
            message.removeLast()
        }
        
        return message
    }
    
    func getAttachmentGifStickersIDs() -> (gifsIDs: [String], stickersIDs: [String]) {
        
        var appliedGifsIds = [String]()
        var appliedStickersIDs = [String]()
        
        attachments.forEach({ attachment in
            switch attachment.item.type {
            case .gif:
                appliedGifsIds.append("\(attachment.item.id)")
            case .image:
                appliedStickersIDs.append("\(attachment.item.id)")
            }
        })
        
        return (gifsIDs: appliedGifsIds, stickersIDs: appliedStickersIDs)
        
    }
}

extension OverlayStickerImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

