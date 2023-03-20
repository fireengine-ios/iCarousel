//
//  CreateCollagePreviewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 7.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import SDWebImage
import UIKit

final class CreateCollagePreviewController: BaseViewController, UITextFieldDelegate, UIScrollViewDelegate  {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        view.layer.borderColor = AppColor.settingsButtonColor.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let router = CreateCollageRouter()
    private var longPressedItem: Int = -1
    private var collagePhotoCount: Int = 0
    private var xRatioConstant: Double = 0
    private var yRatioConstant: Double = 0
    private var xFrameStart: Double = 30
    private var yFrameStart: Double = 100
    private var selectedItems = [SearchItemResponse]()
    private var collageTemplate: CollageTemplateElement?
    private lazy var bottomBarManager = CreateCollageBottomBarManager(delegate: self)
    private var photoSelectType = PhotoSelectType.newPhotoSelection
    var draggedTag = Int()
    var draggedImage = UIImage()
    var lastRotation: CGFloat = 0
    var lastScale: CGFloat = 1
    
    init(collageTemplate: CollageTemplateElement, selectedItems: [SearchItemResponse]) {
        self.collageTemplate = collageTemplate
        self.collagePhotoCount = collageTemplate.shapeCount
        self.selectedItems = selectedItems
        if selectedItems.count > 0 {
            photoSelectType = .changePhotoSelection
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("CreateCollagePreviewController viewDidLoad")
        
        bottomBarManager.setup()
        setLayout()
        createImageView(collageTemplate: collageTemplate!)
        view.backgroundColor = .white
        setTextFieldInNavigationBar(withDelegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bottomBarManager.hide()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ImageViewCollageLongPress"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if navTextField?.text != "+New Collage" {
            StringConstants.collageName = navTextField?.text ?? "+New Collage"
        }
    }
    
    private func createImageView(collageTemplate: CollageTemplateElement) {
        let shapeDetails = collageTemplate.shapeDetails.sorted { $0.id < $1.id }

        for i in 0...shapeDetails.count - 1 {
            if shapeDetails[i].type == "RECTANGLE" {
                let imageWidth = Double(shapeDetails[i].shapeCoordinates[1].x) - Double(shapeDetails[i].shapeCoordinates[0].x)
                let imageHeight = Double(shapeDetails[i].shapeCoordinates[2].y) - Double(shapeDetails[i].shapeCoordinates[1].y)
                let xFirst = Double(shapeDetails[i].shapeCoordinates[0].x)
                let yFirst = Double(shapeDetails[i].shapeCoordinates[0].y)
                let xStart = (xFirst / xRatioConstant)
                let yStart = (yFirst / xRatioConstant)
                let viewFrame = CGRect(x: xStart, y: yStart, width: imageWidth / xRatioConstant, height: imageHeight / xRatioConstant)
                switch photoSelectType {
                case .newPhotoSelection:
                    let imageView = UIImageView(frame: viewFrame)
                    imageView.tag = i
                    imageView.isUserInteractionEnabled = true
                    let tapImage = UITapGestureRecognizer(target: self, action: #selector(thumbnailImageTapped(_:)))
                    imageView.addGestureRecognizer(tapImage)
                    imageView.backgroundColor = AppColor.collageThumbnailColor.color
                    imageView.contentMode = .center
                    imageView.image = Image.iconAddUnselect.image
                    contentView.addSubview(imageView)
                case .changePhotoSelection:
                    let scrollView = UIScrollView()
                    let imageView = UIImageView()
                    createImageThumbnail(scrollView: scrollView, imageView: imageView, viewFrame: viewFrame, index: i, shapeType: shapeDetails[i].type)
                }
            } else if shapeDetails[i].type == "CIRCLE" {
                let radius = Double(shapeDetails[i].shapeCoordinates[0].radius ?? 0) / xRatioConstant
                let imageWidth = radius * 2
                let imageHeight = radius * 2
                let xFirst = Double(shapeDetails[i].shapeCoordinates[0].x)
                let yFirst = Double(shapeDetails[i].shapeCoordinates[0].y)
                let xStart = (xFirst / xRatioConstant) - (radius)
                let yStart = (yFirst / xRatioConstant) - (radius)
                let viewFrame = CGRect(x: xStart, y: yStart, width: imageWidth, height: imageHeight)
                switch photoSelectType {
                case .newPhotoSelection:
                    let imageView = UIImageView(frame: viewFrame)
                    imageView.tag = i
                    imageView.isUserInteractionEnabled = true
                    let tapImage = UITapGestureRecognizer(target: self, action: #selector(thumbnailImageTapped(_:)))
                    imageView.addGestureRecognizer(tapImage)
                    imageView.backgroundColor = AppColor.collageThumbnailColor.color
                    imageView.contentMode = .center
                    imageView.image = Image.iconAddUnselect.image
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    imageView.clipsToBounds = true
                    contentView.addSubview(imageView)
                case .changePhotoSelection:
                    let scrollView = UIScrollView()
                    let imageView = UIImageView()
                    createImageThumbnail(scrollView: scrollView, imageView: imageView, viewFrame: viewFrame, index: i, shapeType: shapeDetails[i].type)
                }
            }
        }
        
        if selectedItems.count > 0 {
            containerView.layer.borderColor = AppColor.collageBorderColor.cgColor
        }
    }
    
    @objc func thumbnailImageTapped(_ sender:AnyObject) {
        router.openSelectPhotosWithNew(collageTemplate: collageTemplate!)
    }
    
    private func createImageThumbnail(scrollView: UIScrollView, imageView: UIImageView, viewFrame: CGRect, index: Int, shapeType: String) {
        scrollView.frame = viewFrame
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        contentView.addSubview(scrollView)
        
        let imageUrl = selectedItems[index].metadata?.mediumUrl
        imageView.sd_setImage(with: imageUrl)
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.tag = index
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.frame.size
        
        if shapeType == "CIRCLE" {
            scrollView.layer.cornerRadius = scrollView.frame.size.width / 2
            scrollView.clipsToBounds = true
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        imageView.addGestureRecognizer(tapGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)

        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(_:)))
        rotationGesture.delegate = self
        imageView.addGestureRecognizer(rotationGesture)
        
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        imageView.addInteraction(dragInteraction)

        let dropInteraction = UIDropInteraction(delegate: self)
        imageView.addInteraction(dropInteraction)
    }
    
    private func saveCollage() {
        print("SAVE COLLAGE")
    }
    
    private func deleteCollage() {
        containerView.subviews.forEach { $0.removeFromSuperview()}
        photoSelectType = .newPhotoSelection
        createImageView(collageTemplate: collageTemplate!)
        bottomBarManager.update(configType: .newPhotoSelection)
    }
    
    private func changeSelectedPhoto() {
        router.openSelectPhotosWithChange(collageTemplate: collageTemplate!, items: selectedItems, selectItemIndex: longPressedItem)
    }
    
    private func cancelCollage() {
        contentView.subviews.forEach { values in
            values.alpha = 1.0
            values.layer.sublayers?.forEach { $0.removeFromSuperlayer()}
        }
        bottomBarManager.update(configType: .newPhotoSelection)
    }
    
    private func createBorder(view: UIView, borderWith: CGFloat) -> CALayer {
        let borderLayer = CALayer()
        let borderFrame = CGRect(x: -5, y: -5, width: view.frame.size.width + 10, height: view.frame.size.height + 10)
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.frame = borderFrame
        borderLayer.cornerRadius = 5.0
        borderLayer.borderWidth = borderWith
        borderLayer.borderColor = AppColor.settingsButtonColor.cgColor
        return borderLayer
    }
    
}

extension CreateCollagePreviewController: UIGestureRecognizerDelegate {
    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else { return }
        view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
        lastScale = sender.scale
        
        if sender.state == .ended {
            let imageView = contentView.subviews[sender.view!.tag].subviews[0] as! UIImageView
            let scrollView = contentView.subviews[sender.view!.tag] as! UIScrollView
            let x = imageView.frame.origin.x
            let y = imageView.frame.origin.y
            scrollView.contentInset = UIEdgeInsets(top: -y, left: -x, bottom: -y, right: -x)
        }
    }

    @objc func rotate(_ sender: UIRotationGestureRecognizer) {
        guard let view = sender.view else { return }
        if sender.state == .began {
            sender.rotation = lastRotation
        }
        view.transform = view.transform.rotated(by: sender.rotation - lastRotation)
        lastRotation = sender.rotation
    }
    
    @objc func tapped(_ sender: UIRotationGestureRecognizer) {
        let shapeDetails = collageTemplate?.shapeDetails.sorted { $0.id < $1.id }
        if sender.view?.tag == longPressedItem {
            bottomBarManager.update(configType: .newPhotoSelection)
            for i in 0...(shapeDetails?.count ?? 1) - 1 {
                contentView.subviews[i].subviews[0].alpha = 1
            }
        } else {
            bottomBarManager.update(configType: .changePhotoSelection)
            for i in 0...(shapeDetails?.count ?? 1) - 1 {
                if sender.view?.tag != i {
                    contentView.subviews[i].subviews[0].alpha = 0.3
                    //contentView.subviews[i].layer.sublayers?.forEach { $0.removeFromSuperlayer()}
                } else {
                    longPressedItem = sender.view?.tag ?? 0
                    contentView.subviews[i].subviews[0].alpha = 1
                    contentView.subviews[i].subviews[0].layer.addSublayer(createBorder(view: contentView.subviews[i].subviews[0], borderWith: 2.0))
                }
            }
        }
    }
}

extension CreateCollagePreviewController {
    private func setLayout() {
        view.addSubview(containerView)
        view.addSubview(contentView)
        
        let viewWidth = view.frame.size.width
        let collageWidth = collageTemplate?.imageWidth
        let collageHeight = collageTemplate?.imageHeight
        let yRatio = Double(collageWidth ?? 1) / Double(collageHeight ?? 1)
        let rightSpace = xFrameStart * 2
        
        contentView.frame = CGRect(x: xFrameStart, y: yFrameStart, width: viewWidth - rightSpace, height: (viewWidth - rightSpace) / yRatio)
        xRatioConstant = Double(collageTemplate?.imageWidth ?? 1) / Double(contentView.frame.size.width)
        containerView.frame = CGRect(x: contentView.frame.origin.x - 12, y: contentView.frame.origin.y - 12, width: contentView.frame.size.width + 24, height: contentView.frame.size.height + 24)
        
        if selectedItems.count > 0 {
            bottomBarManager.show()
        }
    }
}

extension CreateCollagePreviewController: BaseItemInputPassingProtocol {
    //COLLAGE SAVE
    func selectModeSelected() {
        saveCollage()
    }
    
    //COLLAGE DELETE
    func selectAllModeSelected() {
        deleteCollage()
    }
    
    //COLLAGE CHANGE PHOTO
    func changeCover() {
        changeSelectedPhoto()
    }
    
    //COLLAGE CANCEL
    func printSelected() {
        cancelCollage()
    }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        selectedItemsCallback([])
    }
    func operationFinished(withType type: ElementTypes, response: Any?) { }
    func operationFailed(withType type: ElementTypes) { }
    func stopModeSelected() { }
    func delete(all: Bool) { }
    func showOnly(withType type: ElementTypes) { }
    func deSelectAll() { }
    func changePeopleThumbnail() { }
    func openInstaPick() { }
}


extension CreateCollagePreviewController: UIDragInteractionDelegate {

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        var image = UIImage()
        
        for index in 0...contentView.subviews.count - 1 {
            if contentView.subviews[index].subviews[0].tag == interaction.view?.tag {
                let imageView = contentView.subviews[index].subviews[0] as! UIImageView
                image  = imageView.image!
                draggedTag = index
            }
        }
        let item = UIDragItem(itemProvider: NSItemProvider(object: image))
        item.localObject = image
        return [item]
    }

}

extension CreateCollagePreviewController: UIDropInteractionDelegate {

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.items.count == 1
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropLocation = session.location(in: view)
        var operation: UIDropOperation = .cancel
        
        for index in 0...contentView.subviews.count - 1 {
            if contentView.subviews[index].subviews[0].tag == interaction.view?.tag {
                let imageView = contentView.subviews[index].subviews[0] as! UIImageView
                if imageView.frame.contains(dropLocation) {
                    operation = session.localDragSession == nil ? .copy : .move
                    draggedImage = imageView.image!
                } else {
                    operation = .cancel
                }
            }
        }
        return UIDropProposal(operation: operation)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            guard let images = imageItems as? [UIImage] else { return }
            for index in 0...self.contentView.subviews.count - 1 {
                if self.contentView.subviews[index].subviews[0].tag == interaction.view?.tag {
                    let imageView = self.contentView.subviews[index].subviews[0] as! UIImageView
                    imageView.image = images.first
                }
                if self.contentView.subviews[index].subviews[0].tag == self.draggedTag {
                    let imageView = self.contentView.subviews[index].subviews[0] as! UIImageView
                    imageView.image = self.draggedImage
                }
            }
        }
    }

}
