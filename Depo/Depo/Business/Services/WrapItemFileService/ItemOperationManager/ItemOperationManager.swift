//
//  UploadNotificationManager.swift
//  Depo
//
//  Created by Oleg on 27.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol ItemOperationManagerViewProtocol {
    
    func startUploadFile(file: WrapData)
    
    func setProgressForUploadingFile(file: WrapData, progress: Float)
    
    func finishedUploadFile(file: WrapData)
    
    func addFilesToFavorites(items: [Item])
    
    func removeFileFromFavorites(items: [Item])
    
    func deleteItems(items: [Item])
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool
    
}


class ItemOperationManager: NSObject {
    
    static let `default` = ItemOperationManager()
    private var views = [ItemOperationManagerViewProtocol]()
    
    private var currentUploadingObject: WrapData?
    private var currentUploadProgress: Float = 0
    
    func startUpdateView(view: ItemOperationManagerViewProtocol){
        if views.index(where: {$0.isEqual(object: view)}) == nil{
            views.append(view)
        }
        
        if currentUploadingObject != nil{
            view.startUploadFile(file: currentUploadingObject!)
            view.setProgressForUploadingFile(file: currentUploadingObject!, progress: currentUploadProgress)
        }
    }
    
    func stopUpdateView(view: ItemOperationManagerViewProtocol){
        if let index = views.index(where: {$0.isEqual(object: view)}){
            views.remove(at: index)
        }
    }
    
    func startUploadFile(file: WrapData){
        currentUploadingObject = file
        
        DispatchQueue.main.async {
            for view in self.views{
                view.startUploadFile(file: file)
            }
        }
    }
    
    func setProgressForUploadingFile(file: WrapData, progress: Float){
        DispatchQueue.main.async {
            for view in self.views{
                view.setProgressForUploadingFile(file: file, progress: progress)
            }
        }
        
        currentUploadingObject = file
        currentUploadProgress = progress
    }
    
    func finishedUploadFile(file: WrapData){
        DispatchQueue.main.async {
            for view in self.views{
                view.finishedUploadFile(file: file)
            }
        }
        
        currentUploadingObject = nil
        currentUploadProgress = 0
    }
    
    func addFilesToFavorites(items: [Item]){
        DispatchQueue.main.async {
            for view in self.views{
                view.addFilesToFavorites(items: items)
            }
        }
    }
    
    func removeFileFromFavorites(items: [Item]){
        DispatchQueue.main.async {
            for view in self.views{
                view.removeFileFromFavorites(items: items)
            }
        }
    }
    
    func deleteItems(items: [Item]){
        DispatchQueue.main.async {
            for view in self.views{
                view.deleteItems(items: items)
            }
        }
    }
    
}

