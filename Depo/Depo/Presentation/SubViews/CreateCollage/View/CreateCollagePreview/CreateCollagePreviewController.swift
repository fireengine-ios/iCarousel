//
//  CreateCollagePreviewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 7.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class CreateCollagePreviewController: BaseViewController {
    
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
    
    private var collagePhotoCount: Int = 0
    private var selectedItems = [SearchItemResponse]()
    private var collageTemplate: CollageTemplateElement?
    private var xRatioConstant: Double = 0
    private var yRatioConstant: Double = 0
    private var xFrameStart: Double = 30
    private var yFrameStart: Double = 100
    
    init(collageTemplate: CollageTemplateElement, selectedItems: [SearchItemResponse]) {
        self.collageTemplate = collageTemplate
        self.collagePhotoCount = collageTemplate.shapeCount
        self.selectedItems = selectedItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("CreateCollagePreviewController viewDidLoad")
        
        setLayout()
        createImageView(collageTemplate: collageTemplate!, imageCount: selectedItems.count)
        view.backgroundColor = .white
        setTitle(withString: "Create Collage")
    }
    
    private func createImageView(collageTemplate: CollageTemplateElement, imageCount: Int) {
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
                imageView.layer.cornerRadius = 4
                imageView.layer.masksToBounds = false
                imageView.backgroundColor = .red
                contentView.addSubview(imageView)
                    
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
        
        containerView.frame = CGRect(x: contentView.frame.origin.x - 6, y: contentView.frame.origin.y - 6, width: contentView.frame.size.width + 12, height: contentView.frame.size.height + 12)
    }
}
