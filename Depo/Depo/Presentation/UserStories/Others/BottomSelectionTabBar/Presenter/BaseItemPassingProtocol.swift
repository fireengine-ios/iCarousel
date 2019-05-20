//
//  BaseItemPassingProtocol.swift
//  Depo
//
//  Created by Aleksandr on 8/3/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol BaseItemInputPassingProtocol: class {
    
    func operationFinished(withType type: ElementTypes, response: Any?)
    func operationFailed(withType type: ElementTypes)
    
    func showAlert(with message: String)
    
    func selectModeSelected()
    func selectAllModeSelected()
    func deSelectAll()
    func stopModeSelected()

    func printSelected()
    func changeCover()
    
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem])
    
    func openInstaPick()
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems)
}

protocol BaseItemOuputPassingProtocol: class {
    func dismiss(animated: Bool)
    func show(animated: Bool, onView sourceView: UIView?)//
}


extension BaseItemInputPassingProtocol {
    func showAlert(with message: String) {
        DispatchQueue.main.async {
            UIApplication.showErrorAlert(message: message)
        }
    }
}
