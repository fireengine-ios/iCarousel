//
//  PlusMenuItemView.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum FloatingButtonsType {
    case takePhoto
    case upload
    case createAStory
    case newFolder
    case createAlbum
    case uploadFromLifebox
    case uploadFromLifeboxFavorites
    case importFromSpotify
    case uploadFiles
    case uploadDocuments
    case uploadMusic
    case uploadDocumentsAndMusic
    case photopick
    case createCollage
    case createWord
    case createExcel
    case createPowerPoint
    case photoPrint
    
    var title: String {
        switch self {
        case .takePhoto:
            return TextConstants.takePhoto
        case .upload:
            return TextConstants.uploadPhotos
        case .uploadFiles, .uploadDocuments:
            return TextConstants.uploadFiles
        case .uploadMusic:
            return TextConstants.uploadMusic
        case .uploadFromLifebox, .uploadFromLifeboxFavorites:
            return TextConstants.uploadFromLifebox
        case .createAStory:
            return TextConstants.createStory
        case .newFolder:
            return TextConstants.newFolder
        case .createAlbum:
            return TextConstants.createAlbum
        case .importFromSpotify:
            return TextConstants.importFromSpotifyBtn
        case .uploadDocumentsAndMusic:
            return TextConstants.uploadFiles
        case .photopick:
            return TextConstants.myStreamInstaPickTitle
        case .createCollage:
            return localized(.createCollageLabel)
        case .createWord:
            return localized(.createWord)
        case .createExcel:
            return localized(.createExcel)
        case .createPowerPoint:
            return localized(.createPowerPoint)
        case .photoPrint:
            return localized(.photoPrint)
        }
    }
    
    var image: UIImage? {
        switch self {
        case .takePhoto:
            return Image.iconCamera.image
        case .uploadFiles,
             .uploadDocuments,
             .uploadMusic,
             .uploadFromLifebox,
             .uploadFromLifeboxFavorites,
             .uploadDocumentsAndMusic:
            return Image.iconFileUpload.image
        case .upload:
            return Image.iconUploadPhoto.image
        case .createAStory:
            return Image.iconStory.image
        case .newFolder, .createAlbum:
            return Image.iconFolderCreate.image
        case .importFromSpotify:
            return UIImage(named: "ImportFromSpotify")
        case .photopick:
            return Image.iconEffect.image
        case .createCollage:
            return Image.iconEffect.image
        case .createWord:
            return Image.iconFileDocNew.image
        case .createExcel:
            return Image.iconFileXlsNew.image
        case .createPowerPoint:
            return Image.iconFilePptNew.image
        case .photoPrint:
            return Image.iconPrint.image
        }
    }
    
    var action: TabBarViewController.Action {
        switch self {
        case .takePhoto:
            return .takePhoto
        case .upload:
            return .upload
        case .uploadFiles:
            return .uploadFiles
        case .uploadDocuments:
            return .uploadDocuments
        case .uploadMusic:
            return .uploadMusic
        case .uploadFromLifebox:
            return .uploadFromApp
        case .uploadFromLifeboxFavorites:
            return .uploadFromAppFavorites
        case .createAStory:
            return .createStory
        case .newFolder:
            return .createFolder
        case .createAlbum:
            return .createAlbum
        case .importFromSpotify:
            return .importFromSpotify
        case .uploadDocumentsAndMusic:
            return .uploadDocumentsAndMusic
        case .photopick:
            return .photopick
        case .createCollage:
            return .createCollage
        case .createWord:
            return .createWord
        case .createExcel:
            return .createExcel
        case .createPowerPoint:
            return .createPowerPoint
        case .photoPrint:
            return .photoPrint
        }
    }
}

protocol PlusMenuItemViewDelegate: AnyObject {
    func selectPlusMenuItem(action: TabBarViewController.Action)
}

final class PlusMenuItemView: UIView, NibInit {
    
    static func with(type: FloatingButtonsType, delegate: PlusMenuItemViewDelegate?) -> PlusMenuItemView {
        let view = PlusMenuItemView.initFromNib()
        view.setup(with: type)
        view.actionDelegate = delegate
        view.changeVisability(toHidden: true)
        return view
    }
    
    @IBOutlet weak var adjustedLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaDemFont(size: 14)
        }
    }
    @IBOutlet weak var button: UIButton!
    
    private let bottomConstraintOriginalConstant = -(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
    private let height: CGFloat = 65
    private let width: CGFloat = 80
    
    private var type: FloatingButtonsType = .upload
    weak var actionDelegate: PlusMenuItemViewDelegate?
    
    private var bottomConstraint: NSLayoutConstraint?
    private var centerXConstraint: NSLayoutConstraint?
    
    //MARK: -
    
    func setup(with type: FloatingButtonsType) {
        self.type = type
        adjustedLabel.text = type.title
        button.setImage(type.image, for: .normal)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = type.title
    }
    
    func add(to contentView: UIView) {
        contentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        centerXConstraint = centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        bottomConstraint?.activate()
        centerXConstraint?.activate()
        
        widthAnchor.constraint(equalToConstant: width).activate()
        heightAnchor.constraint(equalToConstant: height).activate()
    }
    
    func changeVisability(toHidden hidden: Bool) {
        button.isEnabled = !hidden
        alpha = hidden ? 0 : 1
        if hidden {
            updatePosition(x: 0, bottom: bottomConstraintOriginalConstant)
        }
    }
    
    func updatePosition(x: CGFloat, bottom: CGFloat) {
        centerXConstraint?.constant = x
        bottomConstraint?.constant = bottom
    }
    
    @IBAction private func buttonAction(_ sender: Any) {
        actionDelegate?.selectPlusMenuItem(action: type.action)
    }
    
}
