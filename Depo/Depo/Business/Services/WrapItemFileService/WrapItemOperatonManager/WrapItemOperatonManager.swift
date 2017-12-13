//
//  WrapItemOperatonManager.swift
//  Depo_LifeTech
//
//  Created by Oleg on 27.09.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum OperationType: String{
    case upload                 = "Upload"
    case sync                   = "Sync"
    case download               = "Download"
    case freeAppSpace           = "FreeAppSpace"
    case freeAppSpaceWarning    = "freeAppSpaceWarning"
    case prepareToAutoSync      = "prepareToAutoSync"
}

class Progress {
    var allOperations: Int?
    var completedOperations: Int?
}

class WrapItemOperatonManager: NSObject {
    
    static let `default` = WrapItemOperatonManager()
    
    private var foloversArray = [WrapItemOperationViewProtocol]()
    private var progresForOperation = [OperationType: Progress]()
    
    
    //MARK: registration view
    
    func addViewForNotification(view: WrapItemOperationViewProtocol){
        if foloversArray.index(where: {$0.isEqual(object: view)}) == nil{
            foloversArray.append(view)
        }
        
        let keys = progresForOperation.keys
        for key in keys {
            let progress = progresForOperation[key]
            view.startOperationWith(type: key, allOperations: progress?.allOperations, completedOperations: progress?.completedOperations)
        }
    }
    
    func removeViewForNotification(view: WrapItemOperationViewProtocol){
        if let index = foloversArray.index(where: {$0.isEqual(object: view)}){
            foloversArray.remove(at: index)
        }
        
        let keys = progresForOperation.keys
        for key in keys {
            view.stopOperationWithType(type: key)
        }
    }
    
    private func setProgressForOperation(operation: OperationType, allOperations: Int?, completedOperations: Int?){
        var progress = progresForOperation[operation]
        if (progress == nil){
            progress = Progress()
        }
        progress!.allOperations = allOperations
        progress!.completedOperations = completedOperations
        progresForOperation[operation] = progress
    }
    
    //MARK: sending operation to registred subviews
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?){
        hidePopUpsByDepends(type: type)
        setProgressForOperation(operation: type, allOperations: allOperations, completedOperations: completedOperations)
        DispatchQueue.main.async {
            for notificationView in self.foloversArray{
                notificationView.startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
            }
        }
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ){
        hidePopUpsByDepends(type: type)
        setProgressForOperation(operation: type, allOperations: allOperations, completedOperations: completedOperations)
        DispatchQueue.main.async {
            for notificationView in self.foloversArray{
                notificationView.setProgressForOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
            }
        }
    }
    
    func setProgress(ratio: Float, operationType: OperationType){
        DispatchQueue.main.async {
            for notificationView in self.foloversArray{
                notificationView.setProgress(ratio: ratio, for: operationType)
            }
        }
    }
    
    func stopOperationWithType(type: OperationType){
        progresForOperation[type] = nil
        DispatchQueue.main.async {
            for notificationView in self.foloversArray{
                notificationView.stopOperationWithType(type: type)
            }
        }
    }
    
    func stopAllOperations(){
        for operation in progresForOperation.keys {
            stopOperationWithType(type: operation)
        }
    }
    
    func hidePopUpsByDepends(type: OperationType){
        switch type {
        case .sync:
            stopOperationWithType(type: .prepareToAutoSync)
        default:
            break
        }
    }
    
    //MARK: views for operations
    
    class func popUpViewForOperaion(type: OperationType) -> BaseView{
        switch type {
        case .freeAppSpace, .freeAppSpaceWarning:
            let view = FreeUpSpacePopUp.initFromNib()
            view.configurateWithType(viewType: type)
            return view
        case .download, .sync, .upload:
            let popUp = ProgressPopUp.initFromNib()
            popUp.configurateWithType(viewType: type)
            return popUp
        case .prepareToAutoSync:
            let popUp = PrepareToAutoSync.initFromNib()
            return popUp
        }
    }
    
}
