//
//  WrapItemOperatonManager.swift
//  Depo_LifeTech
//
//  Created by Oleg on 27.09.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum OperationType: String{
    case upload                     = "Upload"
    case sync                       = "Sync"
    case download                   = "Download"
    case freeAppSpace               = "FreeAppSpace"
    case freeAppSpaceLocalWarning   = "freeAppSpaceLocalWarning"
    case freeAppSpaceCloudWarning   = "freeAppSpaceCloudWarning"
    case emptyStorage               = "emptyStorage"
    case prepareToAutoSync          = "prepareToAutoSync"
    case autoUploadIsOff            = "autoUploadIsOff"
    case waitingForWiFi             = "waitingForWiFi"
    case contactBacupEmpty          = "contactBacupEmpty"
    case contactBacupOld            = "contactBacupOld"
}

typealias BlockObject = () -> Void

class Progress {
    var allOperations: Int?
    var completedOperations: Int?
}

class CardsManager: NSObject {
    
    static let `default` = CardsManager()
    
    private var foloversArray = [CardsManagerViewProtocol]()
    private var progresForOperation = [OperationType: Progress]()
    
    var blocks = [BlockObject]()
    
    //MARK: registration view
    
    func addViewForNotification(view: CardsManagerViewProtocol){
        
        if foloversArray.index(where: {$0.isEqual(object: view)}) == nil{
            foloversArray.append(view)
        }
        
        let keys = progresForOperation.keys
        for key in keys {
            let progress = progresForOperation[key]
            view.startOperationWith(type: key, allOperations: progress?.allOperations, completedOperations: progress?.completedOperations)
        }
    }
    
    func removeViewForNotification(view: CardsManagerViewProtocol){
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
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?){
        DispatchQueue.main.async {
            if (!self.canShowPopUpByDepends(type: type)){
                return
            }
            self.hidePopUpsByDepends(type: type)
            
            self.setProgressForOperationWith(type: type, allOperations: allOperations ?? 0, completedOperations: completedOperations ?? 0)
            
            for notificationView in self.foloversArray{
                notificationView.startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
            }
        }
        
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ){
        setProgressForOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int){
        hidePopUpsByDepends(type: type)
        
        DispatchQueue.main.async {
            self.setProgressForOperation(operation: type, allOperations: allOperations, completedOperations: completedOperations)
            
            for notificationView in self.foloversArray{
                
                if let obj = object {
                    notificationView.setProgressForOperationWith(type: type, object: obj, allOperations: allOperations, completedOperations: completedOperations)
                }else{
                    notificationView.setProgressForOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
                }
                
            }
        }
    }
    
    func setProgress(ratio: Float, operationType: OperationType, object: WrapData?){
        DispatchQueue.main.async {
            for notificationView in self.foloversArray{
                notificationView.setProgress(ratio: ratio, for: operationType, object: object)
            }
        }
    }
    
    func stopOperationWithType(type: OperationType){
        
        print("operation stopped ", type.rawValue)
        
        DispatchQueue.main.async {
            self.progresForOperation[type] = nil
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
        case .sync, .upload:
            stopOperationWithType(type: .prepareToAutoSync)
            stopOperationWithType(type: .waitingForWiFi)
            stopOperationWithType(type: .freeAppSpaceLocalWarning)
            stopOperationWithType(type: .freeAppSpace)
        default:
            break
        }
    }
    
    func canShowPopUpByDepends(type: OperationType) -> Bool{
        switch type {
        case .freeAppSpace, .freeAppSpaceLocalWarning:
            let operations: [OperationType] = [.sync, .upload]
            for operation in operations{
                if (progresForOperation[operation] != nil){
                    return false
                }
            }
        default:
            break
        }
        
        return true
    }
    
    //MARK: views for operations
    
    class func popUpViewForOperaion(type: OperationType) -> BaseView{
        switch type {
        case .freeAppSpace:
            let view = FreeUpSpacePopUp.initFromNib()
            view.configurateWithType(viewType: type)
            return view
        case .freeAppSpaceCloudWarning, .freeAppSpaceLocalWarning, .emptyStorage:
            let popUp = StorageCard.initFromNib()
            return popUp
        case .download, .sync, .upload:
            let popUp = ProgressPopUp.initFromNib()
            popUp.configurateWithType(viewType: type)
            return popUp
        case .prepareToAutoSync:
            let popUp = PrepareToAutoSync.initFromNib()
            return popUp
        case .autoUploadIsOff:
            return AutoUploadIsOffPopUp.initFromNib()
        case .waitingForWiFi:
            return WaitingForWiFiPopUp.initFromNib()
        case .contactBacupEmpty:
            return ContactBackupEmpty.initFromNib()
        case .contactBacupOld:
            return ContactBackupOld.initFromNib()
        }
    }
    
}
