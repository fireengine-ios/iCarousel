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
        
        var items = [UIMenuElement]()
        sortActions.forEach { type in
            if type == .share {
                let shareItems = getShareItems(for: item, actionHandler: actionHandler)
                items.append(contentsOf: shareItems)
            } else {
                let item = UIAction(title: type.actionTitle(),
                                    image: type.menuImage,
                                    attributes: type.menuAttributes) { _  in
                    actionHandler(.elementType(type))
                }
                items.append(item)
            }
        }
        
        return UIMenu(title: "",
                      options: .displayInline,
                      children: items)
    }
    
    static func getShareItems(for item: BaseDataSourceItem, actionHandler: @escaping ValueHandler<ActionType>) -> [UIMenuElement] {
        let shareTypes = ShareTypes.allowedTypes(for: [item])
        return shareTypes.map { type in
            UIAction(title: type.actionTitle,
                     image: type.menuImage) { _ in
                actionHandler(.shareType(type))
            }
        }
    }
}

extension ElementTypes {
    var menuImage: UIImage? {
        var imageName: String? = nil
        switch self {
        case .info:
            imageName = "action_info"
        case .delete, .moveToTrash, .moveToTrashShared:
            imageName = "action_delete"
        case .copy:
            imageName = "action_copy"
        case .endSharing:
            imageName = "action_end_share"
        case .leaveSharing:
            imageName = "action_leave_share"
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
        
        return UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    }
    
    @available(iOS 14.0, *)
    var menuAttributes: UIMenuElement.Attributes {
        if isDestructive {
            return [.destructive]
        }
        return []
    }
    
    var isDestructive: Bool {
        isContained(in: [.delete, .endSharing, .leaveSharing, .moveToTrash, .moveToTrashShared])
    }
}

extension ShareTypes {
    
    var menuImage: UIImage? {
        var imageName: String? = nil
        switch self {
        case .link:
            imageName = "action_copy"
        case .original:
            imageName = "action_send_copy"
        case .private:
            imageName = "action_share"
        }
        
        guard let name = imageName else {
            return nil
        }
        
        return UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    }
}
