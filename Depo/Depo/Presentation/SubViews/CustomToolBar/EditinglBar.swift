//
//  EditinglBar.swift
//  Depo
//
//  Created by Aleksandr on 8/2/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum ElementTypes {
    case share
    case info//one for alert one for tab
    case edit
    case delete
    case deleteDeviceOriginal
    case move
    case sync
    case download
    case undetermend
    case rename
    case removeAlbum
    case moveToTrash
    case restore
    
    //used only in alert sheet:
    //photos:
    case createStory
    case createAlbum
    case copy
    case addToFavorites
    case removeFromFavorites
    case addToAlbum
    case backUp
    case addToCmeraRoll
    case removeFromAlbum
    case removeFromFaceImageAlbum
    case print
    case changeCoverPhoto
    case hide
    case unhide
    case smash
    //upload?
    case photos
    case iCloudDrive
    case lifeBox
    case more
    //all files/select
    case select
    case selectAll
    case deSelectAll
    //doc viewing
    case documentDetails
    //music
    case addToPlaylist
    case musicDetails
    case shareAlbum
    case makeAlbumCover
    case albumDetails
    //instaPick
    case instaPick
    
    static var trashState: [ElementTypes] = [.restore, .delete]
    static var hiddenState: [ElementTypes] = [.unhide, .moveToTrash]
    static var activeState: [ElementTypes] = [.hide, .moveToTrash]

    static func detailsElementsConfig(for item: Item, status: ItemStatus, viewType: DetailViewType) -> [ElementTypes] {
        var result: [ElementTypes]
        
        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
        case .trashed:
            result = ElementTypes.trashState
        default:
            if item.isLocalItem {
                result = [.share, .sync, .info]
            } else {
                switch item.fileType {
                case .image, .video:
                    result = [.share, .download]
                    
                    if item.fileType == .image {
                        if Device.isTurkishLocale {
                            result.append(.print)
                        }
                        
                        result.append(.edit)

                        if item.name?.isPathExtensionGif() == false {
                            result.append(.smash)
                        }
                    }

                default:
                    result = [.share, .download, .moveToTrash]
                }
                
                if item.fileType.isContained(in: [.video, .image]) {
                    switch viewType {
                    case .details:
                        result.append(.moveToTrash)
                    case .insideAlbum:
                        result.append(.removeFromAlbum)
                    case .insideFIRAlbum:
                        result.append(.removeFromFaceImageAlbum)
                    }
                }
            }
        }
        
        return result
    }
    
    static func albumElementsConfig(for status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
            
        case .trashed:
            result = ElementTypes.trashState
            if viewType != .bottomBar {
                result.insert(.select, at: 0)
            }
            
        default:
            switch viewType {
            case .bottomBar:
                result = [.share, .download, .addToAlbum]  + ElementTypes.activeState
                
            case .actionSheet:
                result = [.select, .shareAlbum, .download, .removeAlbum, .albumDetails]  + ElementTypes.activeState
                
            case .selectionMode:
                result = [.createStory]
                if Device.isTurkishLocale {
                    result.append(.print)
                }
                result.append(.removeFromAlbum)
            }
        }
        
        return result
    }
    
    static func faceImagePhotosElementsConfig(for item: Item, status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch viewType {
        case .bottomBar:
            switch status {
            case .hidden:
                result = ElementTypes.hiddenState
                
            case .trashed:
                result = ElementTypes.trashState
                
            default:
                result = [.share, .download, .addToAlbum] + ElementTypes.activeState
            }
            
        case .actionSheet:
            result = [.select]

            if item.fileType.isFaceImageType {
                switch status {
                case .hidden:
                    result.append(contentsOf: ElementTypes.hiddenState)
                    
                case .trashed:
                    result.append(contentsOf: ElementTypes.trashState)
                    
                default:
                    result.append(contentsOf: [.changeCoverPhoto] + ElementTypes.activeState)
                }
            }
            
        case .selectionMode:
            switch status {
            case .hidden:
                result = ElementTypes.hiddenState
                
            case .trashed:
                result = ElementTypes.trashState
                
            default:
                result = [.createStory]
                if Device.isTurkishLocale {
                    result.append(.print)
                }
                result.append(.removeFromFaceImageAlbum)
            }
        }
        
        return result
    }
    
    static func filesInFolderElementsConfig(for status: ItemStatus, viewType: UniversalViewType) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
        case .trashed:
            if viewType == .actionSheet {
                result = [.select] + ElementTypes.trashState
            } else {
                result = ElementTypes.trashState
            }
        default:
            switch viewType {
            case .bottomBar:
                result = [.share, .move, .moveToTrash]
            case .actionSheet:
                result = [.select]
            case .selectionMode:
                result = [.rename]
            }
        }

        return result
    }
    
    static func muisicPlayerElementConfig(for status: ItemStatus, item: Item) -> [ElementTypes] {
        var result: [ElementTypes]

        switch status {
        case .hidden:
            result = ElementTypes.hiddenState
        case .trashed:
            result = [.info] + ElementTypes.trashState
        default:
            result = item.favorites ? [.removeFromFavorites] : [.addToFavorites]
        }

        return result
    }
}

typealias AnimationBlock = () -> Void
typealias PreDetermendType = (String, String, String)

class EditinglBar: CustomTabBar {
    
    struct PreDetermendTypes { //use super setup method with these
        static let share = ("ShareButtonIcon", TextConstants.tabBarShareLabel, "")
        static let info = ("InfoButtonIcon", TextConstants.tabBarInfoLabel, "")
        static let edit = ("EditButtonIcon", TextConstants.tabBarEditeLabel, "")
        static let print = ("PrintButtonIcon", TextConstants.tabBarPrintLabel, "")
        static let delete = ("DeleteShareButton", TextConstants.tabBarDeleteLabel, "")
        static let removeAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveAlbumLabel, "")
        static let move = ("MoveButtonIcon", TextConstants.tabBarMoveLabel, "")
        static let addToAlbum = ("MoveButtonIcon", TextConstants.tabBarAddToAlbumLabel, "")
        static let makeCover = ("MoveButtonIcon", TextConstants.tabAlbumCoverAlbumLabel, "")
        static let removeFromAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel, "")//from album
        static let removeFromFaceImageAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel, "")//from album
        static let sync = ("tabbarSync", TextConstants.tabBarSyncLabel, "")
        static let download = ("downloadTB", TextConstants.tabBarDownloadLabel, "")
        static let hide = ("HideButtonIcon", TextConstants.tabBarHideLabel, "")
        static let unhide = ("UnhideButtonIcon", TextConstants.tabBarUnhideLabel, "")
        static let smash = ("SmashButtonIcon", TextConstants.tabBarSmashLabel, "")
        static let restore = ("RestoreButtonIcon", TextConstants.actionSheetRestore, "")
    }
    
    private let tabBarHeight: CGFloat = 49
    
    private let originalY: CGFloat = -49
    private let originalX: CGFloat = 0
    
    private var animationsArray = [AnimationBlock]()

    // MARK: -
    
    class func getFromXib() -> EditinglBar? {
        guard
            let view = UINib(nibName: "EditinglBar", bundle: nil)
                .instantiate(withOwner: nil, options: nil)
                .first as? EditinglBar
        else {
            return nil
        }
        view.config()
        return view
    }
    
    private func config() {
        tintColor = ColorConstants.selectedBottomBarButtonColor
        isTranslucent = false
    }
    
    deinit{
        animationsArray.removeAll()
    }
    
    func show(animated: Bool = true, onView sourceView: UIView) {
        animationWithBlock(needShow: true, withAnimation: animated, onView: sourceView)
    }
    
    func dismiss(animated: Bool = true) {
        animationWithBlock(needShow: false, withAnimation: animated)
    }
    
    private func animateAppearance(with newY: CGFloat, completionBlock: (() -> Void)?) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.frame.origin = CGPoint(x: 0, y: newY)
        }, completion: { _ in
            completionBlock?()
        })
    }
    
    private func animationWithBlock(needShow: Bool, withAnimation: Bool, onView: UIView? = nil) {
        let animationBlock : AnimationBlock = ({ [weak self, weak onView] in
            guard let `self` = self else {
                return
            }
            
            if needShow {
                guard let sourceView = onView else{
                    self.nextAnimation()
                    return
                }
                
                if self.superview != nil {
                    self.nextAnimation()
                    return
                }
                
                sourceView.addSubview(self)
                sourceView.bringSubview(toFront: self)
                let sourceViewSize = sourceView.frame.size
                self.frame = CGRect(x: self.originalX, y: sourceViewSize.height - self.originalY, width: sourceViewSize.width, height: self.tabBarHeight)
                if withAnimation {
                    self.animateAppearance(with: sourceViewSize.height - self.tabBarHeight, completionBlock: { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        self.nextAnimation()
                    })
                } else {
                    self.frame.origin = CGPoint(x: 0, y: sourceViewSize.height - self.tabBarHeight)
                    self.nextAnimation()
                }
            } else {
                if withAnimation {
                    var animationFrame = self.frame.origin.y - self.originalY
                    
                    if #available(iOS 11.0, *) {
                        animationFrame += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                    }
                    
                    self.animateAppearance(with: animationFrame) { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        self.removeFromSuperview()
                        self.nextAnimation()
                    }
                } else {
                    self.frame.origin = CGPoint(x: 0, y: self.frame.origin.y - self.originalY)
                    self.removeFromSuperview()
                    self.nextAnimation()
                }
            }
        })
        
        animationsArray.append(animationBlock)
        if animationsArray.count == 1{
            animationBlock()
        }
    }
    
    private func nextAnimation() {
        if animationsArray.count > 1 {
            if let lastBlock = animationsArray.last{
                animationsArray = [lastBlock]
                lastBlock()
            }
        }else{
            animationsArray.removeAll()
        }
    }
    
    override func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {
        let items = names.map { item -> CustomTabBarItem in
            var image = UIImage(named: item.imageName)
            
            ///red 'delete', 'hide', 'unhide', 'restore' icons
            switch item.imageName {
            case PreDetermendTypes.delete.0,
                 PreDetermendTypes.hide.0,
                 PreDetermendTypes.unhide.0,
                 PreDetermendTypes.restore.0:
                image = image?.withRenderingMode(.alwaysOriginal)
            default: break
            }
            
            return CustomTabBarItem(title: item.title,
                             image: image,
                             tag: 0)
        }
        
        items.forEach { item in
            item.isAccessibilityElement = true
            item.accessibilityLabel = item.title
        }
  
        setItems(items, animated: false)
    }
    
}
