//
//  AlertFilesActionsSheetModuleInput.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol AlertFilesActionsSheetModuleInput: class {

    func showSelectionsAlertSheet()
    
    func showAlertSheet(with types: [ElementTypes], items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?)
    func showAlertSheet(with types: [ElementTypes], items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?, excludeTypes: [ElementTypes])
    
    func showAlertSheet(with types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?)
    
    func showAlertSheet(with items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?)
    
    func showSpecifiedAlertSheet(with item: BaseDataSourceItem, status: ItemStatus, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?)
    
    func showSpecifiedMusicAlertSheet(with item: WrapData, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?)
    
    func onlyPresentAlertSheet(with elements: [ElementTypes], for objects:[Item], sender: Any?)
}
