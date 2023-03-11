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

final class CreateCollagePreviewController: BaseViewController, UITextFieldDelegate {
    
    let router = CreateCollageRouter()
    
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
                let imageView = UIImageView(frame: viewFrame)
                
                imageView.tag = i
                imageView.isUserInteractionEnabled = true
                
                switch photoSelectType {
                case .newPhotoSelection:
                    let tapImage = UITapGestureRecognizer(target: self, action: #selector(thumbnailImageTapped(_:)))
                    imageView.addGestureRecognizer(tapImage)
                    imageView.backgroundColor = AppColor.collageThumbnailColor.color
                    imageView.contentMode = .center
                    imageView.image = Image.iconAddUnselect.image
                case .changePhotoSelection:
                    let longTapImage = UILongPressGestureRecognizer(target: self, action: #selector(actionImage(_:)))
                    imageView.addGestureRecognizer(longTapImage)
                    imageView.contentMode = .scaleToFill
                    let imageUrl = selectedItems[i].metadata?.mediumUrl
                    imageView.sd_setImage(with: imageUrl)
                }
                contentView.addSubview(imageView)
            }
        }
        
        if selectedItems.count > 0 {
            containerView.layer.borderColor = AppColor.collageBorderColor.cgColor
        }
    }
    
    @objc func thumbnailImageTapped(_ sender:AnyObject) {
        router.openSelectPhotosWithNew(collageTemplate: collageTemplate!)
    }
    
    @objc func actionImage(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            let shapeDetails = collageTemplate?.shapeDetails.sorted { $0.id < $1.id }
            if sender.view?.tag == longPressedItem {
                bottomBarManager.update(configType: .newPhotoSelection)
                for i in 0...(shapeDetails?.count ?? 1) - 1 {
                    contentView.subviews[i].alpha = 1
                }
            } else {
                bottomBarManager.update(configType: .changePhotoSelection)
                for i in 0...(shapeDetails?.count ?? 1) - 1 {
                    if sender.view?.tag != i {
                        contentView.subviews[i].alpha = 0.5
                        contentView.subviews[i].layer.sublayers?.forEach { $0.removeFromSuperlayer()}
                    } else {
                        longPressedItem = sender.view?.tag ?? -1
                        contentView.subviews[i].alpha = 1
                        contentView.subviews[i].layer.addSublayer(createBorder(view: contentView.subviews[i], borderWith: 2.0))
                    }
                }
            }
        }
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
    func operationFinished(withType type: ElementTypes, response: Any?) {
    }
    func operationFailed(withType type: ElementTypes) {
    }
    func stopModeSelected() {
    }
    func delete(all: Bool) {
    }
    func showOnly(withType type: ElementTypes) {
    }
    func deSelectAll() {
    }
    func changePeopleThumbnail() {
    }
    
    func openInstaPick() {
    }
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        selectedItemsCallback([])
    }
}
