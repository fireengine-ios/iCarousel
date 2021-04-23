//
//  File.swift
//  Depo
//
//  Created by Andrei Novikau on 10.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

@available(iOS 14.0, *)
final class MenuItemsFabric {

    static func generateMenuForManagingRole(currentState: ElementTypes,
                                            actionHandler: @escaping ValueHandler<ElementTypes>) -> UIMenu {
        let editorItem = UIAction(title: TextConstants.accessPageRoleEditor,
                                  image: currentState == .editorRole ? UIImage(named: "selectedCheckmark") : nil,
                                  attributes: []) { _  in
            actionHandler(.editorRole)
        }

        let viewerItem = UIAction(title: TextConstants.accessPageRoleViewer,
                                  image: currentState == .viewerRole ? UIImage(named: "selectedCheckmark") : nil,
                                  attributes: []) { _  in
            actionHandler(.viewerRole)
        }

        let deleteItem = UIAction(title: TextConstants.accessPageRemoveRole,
                                  image: nil,
                                  attributes: [.destructive]) { _  in
            actionHandler(.removeRole)
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
    
    static func generateMenu(for item: BaseDataSourceItem, status: ItemStatus, actionHandler: @escaping ValueHandler<ElementTypes>) -> UIMenu {
        let actions = ElementTypes.specifiedMoreActionTypes(for: status, item: item)

        
        let selectAction = actions.first(where: { $0 == .select })
        let infoAction = actions.first(where: { $0 == .info })
        let sortedActions = actions.sorted { !$0.isDestructive && $1.isDestructive }
        
        let mainActions = sortedActions.filter { !$0.isContained(in: [.info, .select]) }
        
        var selectMenu: UIMenu? = nil
        if let selectAction = selectAction {
            let selectItem = UIAction(title: selectAction.actionTitle,
                                    image: selectAction.menuImage,
                                    attributes: selectAction.menuAttributes) { _  in
                actionHandler(selectAction)
            }
            
            selectMenu = UIMenu(title: "",
                              identifier: UIMenu.Identifier(rawValue: "select"),
                              options: .displayInline,
                              children: [selectItem])
        }
        
        var infoMenu: UIMenu? = nil
        if let infoAction = infoAction {
            let infoItem = UIAction(title: infoAction.actionTitle,
                                    image: infoAction.menuImage,
                                    attributes: infoAction.menuAttributes) { _  in
                actionHandler(infoAction)
            }
            
            infoMenu = UIMenu(title: "",
                              identifier: UIMenu.Identifier(rawValue: "info"),
                              options: .displayInline,
                              children: [infoItem])
        }
        
        
        var mainItems = [UIMenuElement]()
        mainActions.forEach { type in
            
            let item = UIAction(title: type.actionTitle,
                                image: type.menuImage,
                                attributes: type.menuAttributes) { _  in
                actionHandler(type)
            }
            mainItems.append(item)
        }
        
        let mainMenu = UIMenu(title: "",
                              identifier: UIMenu.Identifier(rawValue: "main"),
                              options: .displayInline,
                              children: mainItems)
        
        let validMenus = [selectMenu, mainMenu, infoMenu].compactMap { $0 }
        
        return UIMenu(title: "",
                      children: validMenus)
    }
    
    static func getShareItems(for item: BaseDataSourceItem, actionHandler: @escaping ValueHandler<ElementTypes>) -> [UIMenuElement] {
        let shareTypes = allowedShareTypes(for: [item])
        return shareTypes.map { type in
            UIAction(title: type.actionTitle,
                     image: type.menuImage) { _ in
                actionHandler(type)
            }
        }
    }
    
    static private func allowedShareTypes(for items: [BaseDataSourceItem]) -> [ElementTypes] {
        guard let items = items as? [Item] else {
            assertionFailure()
            return []
        }
        
        let isOriginallDisabled = items.contains(where: { !($0.privateSharePermission?.granted?.contains(.read) ?? false) })
        let isPrivateDisabled = items.contains(where: { !($0.privateSharePermission?.granted?.contains(.writeAcl) ?? false) })
        
        var allowedTypes = [ElementTypes]()
        
        if items.contains(where: { $0.fileType == .folder}) {
            allowedTypes = [.share, .privateShare]
        } else if items.contains(where: { return $0.fileType != .image && $0.fileType != .video && !$0.fileType.isDocumentPageItem && $0.fileType != .audio}) {
            allowedTypes = []
        } else {
            allowedTypes = [.share, .privateShare]
        }
        
        if items.count > NumericConstants.numberOfSelectedItemsBeforeLimits || isOriginallDisabled {
            allowedTypes.remove(.share)
        }
        
        if isPrivateDisabled {
            allowedTypes.remove(.privateShare)
        }
        
        
        if items.contains(where: { $0.isLocalItem }) {
            allowedTypes.remove(.privateShare)
        }
        
        return allowedTypes
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
            let item = UIAction(title: element.actionTitle,
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
                imageName = "infoButton"
            case .select:
                imageName = "selectButton"
            case .moveToTrash, .moveToTrashShared, .deletePermanently:
                imageName = "trashButton"
            case .copy:
                imageName = "copyLinkButton"
            case .endSharing, .leaveSharing:
                imageName = "endSharingButton"
            case .move:
                imageName = "turnDownRightArrow"
            case .share:
                imageName = "turnUpRightArrow"
            case .privateShare:
                imageName = "shareButton"
            case .addToFavorites, .removeFromFavorites:
                imageName = "action_favorite"
            case .download, .downloadDocument:
                imageName = "downloadButton"
            case .restore:
                imageName = "restoreButton"
            case .rename:
                imageName = "renameButton"
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
        isContained(in: [.moveToTrash, .moveToTrashShared, .deletePermanently])
    }
}
