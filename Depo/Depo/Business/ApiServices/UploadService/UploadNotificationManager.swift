//
//  UploadNotificationManager.swift
//  Depo
//
//  Created by Oleg on 27.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol UploadNotificationManagerProtocol {
    
    func startUploadFile(file: WrapData)
    
    func setProgressForUploadingFile(file: WrapData, progress: Float)
    
    func finishedUploadFile(file: WrapData)
    
    func isEqual(object: UploadNotificationManagerProtocol) -> Bool
    
}


class UploadNotificationManager: NSObject {
    
    static let `default` = UploadNotificationManager()
    private var views = [UploadNotificationManagerProtocol]()
    
    private var currentUploadingObject: WrapData?
    private var currentUploadProgress: Float = 0
    
    func startUpdateView(view: UploadNotificationManagerProtocol){
        if views.index(where: {$0.isEqual(object: view)}) == nil{
            views.append(view)
        }
        
        if currentUploadingObject != nil{
            view.startUploadFile(file: currentUploadingObject!)
            view.setProgressForUploadingFile(file: currentUploadingObject!, progress: currentUploadProgress)
        }
    }
    
    func stopUpdateView(view: UploadNotificationManagerProtocol){
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
    
}
