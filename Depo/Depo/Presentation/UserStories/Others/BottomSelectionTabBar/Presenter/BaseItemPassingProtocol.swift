//
//  BaseItemPassingProtocol.swift
//  Depo
//
//  Created by Aleksandr on 8/3/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol BaseItemInputPassingProtocol: AnyObject {
    
    func operationFinished(withType type: ElementTypes, response: Any?)
    func operationFailed(withType type: ElementTypes)
    func successPopupClosed()
    func successPopupWillAppear()
    
    func showAlert(with message: String)
    
    func selectModeSelected()
    func selectAllModeSelected()
    func deSelectAll()
    func stopModeSelected()

    func printSelected()
    func changeCover()
    func changePeopleThumbnail()
        
    func getFIRParent() -> Item?
    
    func openInstaPick()
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems)
    
    func delete(all: Bool)
    func showOnly(withType type: ElementTypes)
    
    func onlyOfficeFilterSuccess(documentType: OnlyOfficeFilterType, items: [WrapData])
}

// To make it optional
extension BaseItemInputPassingProtocol {
    func delete(all: Bool) {}
    func showOnly(withType type: ElementTypes) {}
    func onlyOfficeFilterSuccess(documentType: OnlyOfficeFilterType, items: [WrapData]) {}
    func timelineShare() {}
}

protocol BaseItemOuputPassingProtocol: AnyObject {
    func dismiss(animated: Bool)
    func show(animated: Bool, onView sourceView: UIView?)
}


extension BaseItemInputPassingProtocol {
    func showAlert(with message: String) {
        DispatchQueue.main.async {
            UIApplication.showErrorAlert(message: message)
        }
    }
    
    func successPopupClosed() {}
    
    func successPopupWillAppear() {}
    
    func getFIRParent() -> Item? {
        return nil
    }
}
