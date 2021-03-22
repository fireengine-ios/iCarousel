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

    static func generateMenuForManagingRole(currentState: ElementTypes,
                                            actionHandler: @escaping ValueHandler<ActionType>) -> UIMenu {
        let editorItem = UIAction(title: TextConstants.accessPageRoleEditor,
                                  image: currentState == .editorRole ? UIImage(named: "selected-checkmark") : nil,
                                  attributes: []) { _  in
            actionHandler(.elementType(.editorRole))
        }

        let viewerItem = UIAction(title: TextConstants.accessPageRoleViewer,
                                  image: currentState == .viewerRole ? UIImage(named: "selected-checkmark") : nil,
                                  attributes: []) { _  in
            actionHandler(.elementType(.viewerRole))
        }

        let deleteItem = UIAction(title: TextConstants.accessPageRemoveRole,
                                  image: nil,
                                  attributes: [.destructive]) { _  in
            actionHandler(.elementType(.removeRole))
        }

        return UIMenu(title: "",
                      identifier: UIMenu.Identifier(rawValue: "selectRoleAction"),
                      options: .displayInline,
                      children: [
                        editorItem,
                        viewerItem,
                        deleteItem
                      ])
    }
    
    static func generateMenu(for item: BaseDataSourceItem, status: ItemStatus, actionHandler: @escaping ValueHandler<ActionType>) -> UIMenu {
        let actions = ElementTypes.specifiedMoreActionTypes(for: status, item: item)

        
        let selectAction = actions.first(where: { $0 == .select })
        let infoAction = actions.first(where: { $0 == .info })
        let sortedActions = actions.sorted { !$0.isDestructive && $1.isDestructive }
        
        let mainActions = sortedActions.filter { !$0.isContained(in: [.info, .select]) }
        
        var selectMenu: UIMenu? = nil
        if let selectAction = selectAction {
            let selectItem = UIAction(title: selectAction.actionTitle(),
                                    image: selectAction.menuImage,
                                    attributes: selectAction.menuAttributes) { _  in
                actionHandler(.elementType(selectAction))
            }
            
            selectMenu = UIMenu(title: "",
                              identifier: UIMenu.Identifier(rawValue: "select"),
                              options: .displayInline,
                              children: [selectItem])
        }
        
        var infoMenu: UIMenu? = nil
        if let infoAction = infoAction {
            let infoItem = UIAction(title: infoAction.actionTitle(),
                                    image: infoAction.menuImage,
                                    attributes: infoAction.menuAttributes) { _  in
                actionHandler(.elementType(infoAction))
            }
            
            infoMenu = UIMenu(title: "",
                              identifier: UIMenu.Identifier(rawValue: "info"),
                              options: .displayInline,
                              children: [infoItem])
        }
        
        
        var mainItems = [UIMenuElement]()
        mainActions.forEach { type in
            if type == .share {
                let shareItems = getShareItems(for: item, actionHandler: actionHandler)
                mainItems.append(contentsOf: shareItems)
            } else {
                let item = UIAction(title: type.actionTitle(),
                                    image: type.menuImage,
                                    attributes: type.menuAttributes) { _  in
                    actionHandler(.elementType(type))
                }
                mainItems.append(item)
            }
        }
        
        let mainMenu = UIMenu(title: "",
                              identifier: UIMenu.Identifier(rawValue: "main"),
                              options: .displayInline,
                              children: mainItems)
        
        let validMenus = [selectMenu, mainMenu, infoMenu].compactMap { $0 }
        
        return UIMenu(title: "",
                      children: validMenus)
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
    
    static func privateShareUserRoleMenu(roles: [PrivateShareUserRole], currentRole: PrivateShareUserRole, completion: @escaping ValueHandler<PrivateShareUserRole>) -> UIMenu {
        
        let actions: [UIAction] = roles.compactMap { role in
            let actionState: UIAction.State = (role == currentRole) ? .on : .off
            return UIAction(title: role.selectionTitle, state: actionState) { _ in
                completion(role)
            }
        }
        
        return UIMenu(title: "", children: actions)
    }
    
    static func createMenu(bottomBarActions: [BottomBarActionType], actionHandler: @escaping ValueHandler<BottomBarActionType>) -> UIMenu {
        let infoMenuActions = bottomBarActions.filter { $0 == .info }
        let generalMenuActions = bottomBarActions.filter { !$0.toElementType.isDestructive && $0 != .info }
        let destructiveMenuActions = bottomBarActions.filter { $0.toElementType.isDestructive }
        
        let infoMenu = constractInlineMenu(from: infoMenuActions, identifier: UIMenu.Identifier("info"), actionHandler: actionHandler)
        let generalMenu = constractInlineMenu(from: generalMenuActions, identifier: UIMenu.Identifier("general"), actionHandler: actionHandler)
        let destructiveMenu = constractInlineMenu(from: destructiveMenuActions, identifier: UIMenu.Identifier("destructive"), actionHandler: actionHandler)
      
        return UIMenu(title: "", children: [infoMenu, generalMenu, destructiveMenu])
    }
    
    static private func constractInlineMenu(from bottomBarActions: [BottomBarActionType], identifier: UIMenu.Identifier, actionHandler: @escaping ValueHandler<BottomBarActionType>) -> UIMenu {
        
        var menuItems = [UIMenuElement]()
        bottomBarActions.forEach { bottomAction in
            let element = bottomAction.toElementType
            let item = UIAction(title: element.actionTitle(),
                                image: element.menuImage,
                                attributes: element.menuAttributes) { _  in
                actionHandler(bottomAction)
            }
            menuItems.append(item)
        }
        
        return UIMenu(title: "", identifier: identifier, options: .displayInline, children: menuItems)
    }
}

extension ElementTypes {
    var menuImage: UIImage? {
        var imageName: String? = nil
        switch self {
        case .info:
            imageName = "info"
        case .select:
            imageName = "select"
        case .delete, .moveToTrash, .moveToTrashShared, .deletePermanently:
            imageName = "trash"
        case .copy:
            imageName = "copy-link"
        case .endSharing:
            imageName = "end-sharing"
        case .leaveSharing:
            imageName = "action_leave_share"
        case .move:
            imageName = "move"
        case .share:
            imageName = "share-private"
        case .addToFavorites, .removeFromFavorites:
            imageName = "action_favorite"
        case .download, .downloadDocument:
            imageName = "download"
        case .restore:
            imageName = "action_restore"
        case .rename:
            imageName = "rename"
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
        isContained(in: [.delete, .moveToTrash, .moveToTrashShared, .deletePermanently])
    }
}

extension ShareTypes {
    
    var menuImage: UIImage? {
        var imageName: String? = nil
        switch self {
        case .link:
            imageName = "copy-link"
        case .original:
            imageName = "share-copy"
        case .private:
            imageName = "share-private"
        }
        
        guard let name = imageName else {
            return nil
        }
        
        return UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    }
}
