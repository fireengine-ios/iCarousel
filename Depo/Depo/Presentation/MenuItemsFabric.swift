//
//  File.swift
//  Depo
//
//  Created by Andrei Novikau on 10.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

@available(iOS 14.0, *)
final class MenuItemsFabric {
    
    static func generateMenu(for item: BaseDataSourceItem, status: ItemStatus, actionHandler: @escaping ValueHandler<ElementTypes>) -> UIMenu {
        let actions = ElementTypes.specifiedMoreActionTypes(for: status, item: item)
        
        let items = actions.map { type in
            UIAction(title: type.actionTitle(),
                     image: type.menuImage,
                     attributes: type.menuAttributes) { _  in
                actionHandler(type)
            }
        }
        
        return UIMenu(title: item.name ?? "",
                      options: .displayInline,
                      children: items)
    }

}

extension ElementTypes {
    var menuImage: UIImage? {
        switch self {
        case .info:
            return UIImage(named: "action_info")
        case .delete, .moveToTrash, .moveToTrashShared, .removeAlbum:
            return UIImage(named: "action_delete")
        case .copy:
            return UIImage(named: "action_copy")
        case .endSharing:
            return UIImage(named: "action_end_share")
        case .leaveSharing:
            return UIImage(named: "action_leave_share")
        case .removeFromAlbum, .removeFromFaceImageAlbum:
            return UIImage(named: "action_remove")
        case .move:
            return UIImage(named: "action_move")
        case .share:
            return UIImage(named: "action_share")
        case .addToFavorites, .removeFromFavorites:
            return UIImage(named: "action_favorite")
        case .download:
            return UIImage(named: "downloadTB")
        default:
            return nil
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
