//
//  PrivateShareSharedPlusButtonActtionManager.swift
//  Depo
//
//  Created by Alex Developer on 23.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

protocol PrivateShareSharedPlusButtonActtionDelegate: class {
    
    func subPlusActionPressed(type: TabBarViewController.Action)
    
}

final class PrivateShareSharedPlusButtonActtionManager {
    
    private lazy var alertPresenter: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = delegate
        return alert
    }()
    
    private weak var delegate: BaseItemInputPassingProtocol!
    
    weak var actionDelegate: PrivateShareSharedPlusButtonActtionDelegate?
    
    init(delegate: BaseItemInputPassingProtocol) {
        self.delegate = delegate
    }
    
    func showActions(for privateShareTypes: [FloatingButtonsType], sender: Any?, actionsDelegate: PrivateShareSharedPlusButtonActtionDelegate) {
        //in case if it's  ios14 action shall be handled by UIMenu, that was settuped in PrivateShareSharedFilesViewController
        guard Device.operationSystemVersionLessThen(14) else {
            return
        }
        
        actionDelegate = actionsDelegate
        alertPresenter.showSubPlusSheet(with: generateAlertActions(for: privateShareTypes), sender: sender, viewController: delegate as? ViewController)
        
    }
    
    @available(iOS 14.0, *)
    func generateMenu(for subPlusButtonTypes: [FloatingButtonsType], actionsDelegate: PrivateShareSharedPlusButtonActtionDelegate) -> UIMenu {
        
        actionDelegate = actionsDelegate
        
        let relatedActions = generateActions(for: subPlusButtonTypes)
        
        return UIMenu(title: "",
                      identifier: UIMenu.Identifier(rawValue: "PlusButton"),
                      options: .displayInline,
                      children: relatedActions)
    }
    
    @available(iOS 14.0, *)
    func generateActions(for subPlusButtonTypes: [FloatingButtonsType]) -> [UIAction] {

        let actions: [UIAction] = subPlusButtonTypes.map { type in
            return UIAction(title: type.title,
                            image: type.image,
                            attributes: []) { _  in
                self.actionDelegate?.subPlusActionPressed(type: type.action)
            }
        }
        return actions
    }
    
    func generateAlertActions(for subPlusButtonTypes: [FloatingButtonsType]) -> [UIAlertAction] {
        let actions: [UIAlertAction] = subPlusButtonTypes.map { type in
            return UIAlertAction(title: type.title, style: .default) {_ in
                self.actionDelegate?.subPlusActionPressed(type: type.action)
            }
        }
        return actions
    }
}
