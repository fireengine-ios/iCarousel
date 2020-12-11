//
//  File.swift
//  Depo
//
//  Created by Andrei Novikau on 10.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum ActionType {
    case elementType(ElementTypes)
    case shareType(ShareTypes)
}

@available(iOS 14.0, *)
final class MenuItemsFabric {
    
    static func generateMenu(for item: BaseDataSourceItem, status: ItemStatus, actionHandler: @escaping ValueHandler<ActionType>) -> UIMenu {
        let actions = ElementTypes.specifiedMoreActionTypes(for: status, item: item)
        let sortActions = actions.sorted { !$0.isDestructive && $1.isDestructive }
        
        let items = sortActions.map { type -> UIMenuElement in
            if type == .share {
                return getShareMenu(for: item, actionHandler: actionHandler)
            } else {
                return UIAction(title: type.actionTitle(),
                                image: type.menuImage,
                                attributes: type.menuAttributes) { _  in
                    actionHandler(.elementType(type))
                }
            }
        }
        
        return UIMenu(title: item.name ?? "",
                      identifier: .file,
                      options: .displayInline,
                      children: items)
    }
    
    static func getShareMenu(for item: BaseDataSourceItem, actionHandler: @escaping ValueHandler<ActionType>) -> UIMenuElement {
        let shareTypes = ShareTypes.allowedTypes(for: [item])
        if shareTypes.count == 1, let type = shareTypes.first {
            return UIAction(title: type.actionTitle,
                            image: type.menuImage) { _ in
                actionHandler(.shareType(type))
            }
        } else {
            let items = shareTypes.map { type in
                return UIAction(title: type.actionTitle,
                                image: type.menuImage) { _ in
                    actionHandler(.shareType(type))
                }
            }
            return UIMenu(title: ElementTypes.share.actionTitle(),
                          image: ElementTypes.share.menuImage,
                          identifier: .share,
                          children: items)
        }
    }
}

extension ElementTypes {
    var menuImage: UIImage? {
        var imageName: String? = nil
        switch self {
        case .info:
            imageName = "action_info"
        case .delete, .moveToTrash, .moveToTrashShared, .removeAlbum:
            imageName = "action_delete"
        case .copy:
            imageName = "action_copy"
        case .endSharing:
            imageName = "action_end_share"
        case .leaveSharing:
            imageName = "action_leave_share"
        case .removeFromAlbum, .removeFromFaceImageAlbum:
            imageName = "action_remove"
        case .move:
            imageName = "action_move"
        case .share:
            imageName = "action_share"
        case .addToFavorites, .removeFromFavorites:
            imageName = "action_favorite"
        case .download, .downloadDocument:
            imageName = "downloadTB"
        case .restore:
            imageName = "RestoreButtonIcon"
        default:
            return nil
        }
        
        guard let name = imageName else {
            return nil
        }
        
        let image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        if isDestructive {
            return image?.mask(with: ColorConstants.choosenSelectedButtonColor)
        } else {
            return image?.mask(with: ColorConstants.marineTwo)
        }
    }
    
    @available(iOS 14.0, *)
    var menuAttributes: UIMenuElement.Attributes {
        if isDestructive {
            return [.destructive]
        }
        return []
    }
    
    var isDestructive: Bool {
        isContained(in: [.delete, .endSharing, .leaveSharing, .moveToTrash, .moveToTrashShared, .removeAlbum])
    }
}

extension ShareTypes {
    
    var menuImage: UIImage? {
        var imageName: String? = nil
        switch self {
        case .link:
            imageName = "action_copy"
        case .original:
            imageName = "action_copy"
        case .private:
            imageName = "action_share"
        }
        
        guard let name = imageName else {
            return nil
        }
        
        let image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        return image?.mask(with: ColorConstants.marineTwo)
    }
}
