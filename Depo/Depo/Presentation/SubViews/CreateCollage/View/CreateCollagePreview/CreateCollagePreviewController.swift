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

final class CreateCollagePreviewController: BaseViewController, UIScrollViewDelegate  {
    
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
    
    private lazy var infoImage: UIImageView = {
        let view = UIImageView()
        view.image = Image.iconInfo.image
        view.isHidden = true
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let view = UILabel()
        view.text = localized(.createCollageInfoLabel)
        view.textColor = AppColor.label.color
        view.font = .appFont(.medium, size: 12)
        view.isHidden = true
        return view
    }()
    
    private lazy var okRightButton = UIBarButtonItem(image: Image.iconSelectCheck.image,
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(okRightButtonAction))
    
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
    private var contentviewBackGroundImage = UIImage()
    
    let uploadService = UploadService()
    
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
        view.backgroundColor = AppColor.background.color
        setTextFieldInNavigationBar(withDelegate: self)
        isHiddenControl()
        keyboardDoneButton()
        
        let imagePathUrl = URL(string: collageTemplate!.collageImagePath)!
        SDWebImageDownloader.shared().downloadImage(with: imagePathUrl) { [weak self] image, _, _, _ in
            let pathImage = image!
            let scaledImageSize = CGSize(width: (self?.contentView.frame.width)!, height: (self?.contentView.frame.height)!)
            let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
            let scaledImage = renderer.image { _ in
                image!.draw(in: CGRect(origin: .zero, size: scaledImageSize))
            }
            self?.contentviewBackGroundImage = scaledImage
            self?.createImageView(collageTemplate: (self?.collageTemplate!)!)
        }
    }
    
    private func isHiddenControl() {
        switch photoSelectType {
        case .newPhotoSelection:
            infoImage.isHidden = true
            infoLabel.isHidden = true
        case .changePhotoSelection:
            infoImage.isHidden = false
            infoLabel.isHidden = false
        }
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
        if navTextField?.text != localized(.createCollagePreviewMainTitle) {
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
                    imageView.layer.borderWidth = 1.0
                    imageView.layer.borderColor = AppColor.darkBackground.cgColor
                    contentView.backgroundColor = UIColor(patternImage: contentviewBackGroundImage)
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
                    imageView.layer.borderWidth = 1.0
                    imageView.layer.borderColor = AppColor.darkBackground.cgColor
                    contentView.backgroundColor = UIColor(patternImage: contentviewBackGroundImage)
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
        imageView.sd_setImage(with: imageUrl) { (image, error, cache, url) in
            if self.selectedItems.count - 1 == index {
                self.contentView.backgroundColor = UIColor(patternImage: self.contentviewBackGroundImage)
            }
        }
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.tag = index
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        let image: UIImage = takeScreenshot(of: contentView)
        let name: String = StringConstants.collageName
        let imageData = image.jpegData(compressionQuality: 0.9)!
        let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
        let wrapData = WrapData(imageData: imageData, isLocal: true)
        
        wrapData.name = name
        wrapData.patchToPreview = PathForItem.remoteUrl(url)

        showSpinner()
        UploadService.default.uploadFileList(items: [wrapData], uploadType: .upload, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, isCollage: true, success: {
            DispatchQueue.main.async {
                self.hideSpinner()
                self.router.openForYou()
            }
        }, fail: {value in }, returnedUploadOperation: { _ in })
        
    }
    
    private func deleteCollage() {
        containerView.subviews.forEach { $0.removeFromSuperview()}
        photoSelectType = .newPhotoSelection
        createImageView(collageTemplate: collageTemplate!)
        bottomBarManager.hide()
    }
    
    private func changeSelectedPhoto() {
        router.openSelectPhotosWithChange(collageTemplate: collageTemplate!, items: selectedItems, selectItemIndex: longPressedItem)
    }
    
    private func cancelCollage() {
        contentView.subviews.forEach { values in
            values.subviews[0].alpha = 1.0
        //    values.layer.sublayers?.forEach { $0.removeFromSuperlayer()}
        }
        bottomBarManager.update(configType: .newPhotoSelection)
    }
    
    private func createBorder(view: UIView, borderWith: CGFloat) -> CALayer {
        let borderLayer = CALayer()
        let borderFrame = CGRect(x: view.frame.minX - 5.0, y: view.frame.minY - 5.0, width: view.frame.size.width + 10, height: view.frame.size.height + 10)
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.frame = borderFrame
        borderLayer.cornerRadius = 5.0
        borderLayer.borderWidth = borderWith
        borderLayer.borderColor = AppColor.settingsButtonColor.cgColor
        return borderLayer
    }
    
    func takeScreenshot(of view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: view.bounds.width, height: view.bounds.height),
            false,
            2
        )
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenshot
    }
    
}

extension CreateCollagePreviewController: UIGestureRecognizerDelegate {
    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view else { return }
        view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
        
        let defaultFrame = contentView.subviews[sender.view!.tag].frame
        
        if sender.state == .ended {
            let imageView = contentView.subviews[sender.view!.tag].subviews[0] as! UIImageView
            let scrollView = contentView.subviews[sender.view!.tag] as! UIScrollView
            
            if defaultFrame.width >= imageView.frame.size.width || defaultFrame.height >= imageView.frame.size.height {
                imageView.frame = defaultFrame
            }
            
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
            longPressedItem = -1
        } else {
            bottomBarManager.update(configType: .changePhotoSelection)
            for i in 0...(shapeDetails?.count ?? 1) - 1 {
                if sender.view?.tag != i {
                    contentView.subviews[i].subviews[0].alpha = 0.3
                    //contentView.subviews[i].layer.sublayers?.forEach { $0.removeFromSuperlayer()}
                } else {
                    longPressedItem = sender.view?.tag ?? 0
                    contentView.subviews[i].subviews[0].alpha = 1
                    //contentView.subviews[i].subviews[0].layer.addSublayer(createBorder(view: contentView.subviews[i].subviews[0], borderWith: 2.0))
                }
            }
        }
    }
    
    private func keyboardDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: false)
        navTextField?.inputAccessoryView = toolBar
    }
    
    @objc private func doneClicked() {
        StringConstants.collageName = navTextField?.text ?? ""
        navTextField?.endEditing(true)
    }
    
    @objc private func okRightButtonAction() {
        doneClicked()
    }
    
}

extension CreateCollagePreviewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == localized(.createCollagePreviewMainTitle) {
            textField.text = ""
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count ?? 0 == 0 {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = okRightButton
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.text?.count == 0 {
            textField.text = localized(.createCollagePreviewMainTitle)
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneClicked()
        if textField.text?.count == 0 {
            textField.text = localized(.createCollagePreviewMainTitle)
            navigationItem.rightBarButtonItem = nil
        }
        return true
    }
}

extension CreateCollagePreviewController {
    private func setLayout() {
        view.addSubview(containerView)
        view.addSubview(contentView)
        view.addSubview(infoImage)
        view.addSubview(infoLabel)
        
        let viewWidth = view.frame.size.width
        let collageWidth = collageTemplate?.imageWidth
        let collageHeight = collageTemplate?.imageHeight
        let yRatio = Double(collageWidth ?? 1) / Double(collageHeight ?? 1)
        let rightSpace = xFrameStart * 2
        
        contentView.frame = CGRect(x: xFrameStart, y: yFrameStart, width: viewWidth - rightSpace, height: (viewWidth - rightSpace) / yRatio)
        xRatioConstant = Double(collageTemplate?.imageWidth ?? 1) / Double(contentView.frame.size.width)
        containerView.frame = CGRect(x: contentView.frame.origin.x - 12, y: contentView.frame.origin.y - 12, width: contentView.frame.size.width + 24, height: contentView.frame.size.height + 24)
        
        infoImage.frame = CGRect(x: containerView.frame.minX, y: containerView.frame.maxY + 20, width: 20, height: 20)
        infoLabel.frame = CGRect(x: infoImage.frame.maxX + 5, y: containerView.frame.maxY + 20, width: containerView.frame.maxX, height: 20)
        
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
                let scrollView = contentView.subviews[index] as! UIScrollView
                if scrollView.frame.contains(dropLocation) {
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


extension UIApplication {

    func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return windows.first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }

    func makeSnapshot() -> UIImage? { return getKeyWindow()?.layer.makeSnapshot() }
}


extension CALayer {
    func makeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
}

extension UIView {
    func makeSnapshot() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        } else {
            return layer.makeSnapshot()
        }
    }
}

extension UIImage {
    convenience init?(snapshotOf view: UIView) {
        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
