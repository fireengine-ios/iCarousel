//
//  WrapItemOperatonManager.swift
//  Depo_LifeTech
//
//  Created by Oleg on 27.09.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

enum OperationType: String {
    case upload                     = "Upload"
    case sharedWithMeUpload         = "SharedWithMeUpload"
    case download                   = "Download"
    case prepareQuickScroll         = "prepareQuickScroll"
//    case preparePhotosQuickScroll   = "preparePhotosQuickScroll"
//    case prepareVideosQuickScroll   = "prepareVideosQuickScroll"
    case waitingForWiFi             = "waitingForWiFi"
    
    case freeAppSpaceLocalWarning   = "freeAppSpaceLocalWarning"
    case freeAppSpaceCloudWarning   = "freeAppSpaceCloudWarning"
    case emptyStorage               = "emptyStorage"
}

typealias BlockObject = VoidHandler

class Progress {
    var allOperations: Int?
    var completedOperations: Int?
    var percentProgress: Float?
    var lastObject: Item?
}

class CardsManager: NSObject {
    
    static let `default` = CardsManager()
    
    private var foloversArray = [CardsManagerViewProtocol]()
    private var progresForOperation = [OperationType: Progress]()
    private var homeCardsObjects = [HomeCardResponse]()
    private var deletedCards = Set<OperationType>()
    
    var cardsThatStartedByDevice: [OperationType] {
        return [.upload, .download, .sharedWithMeUpload, .prepareQuickScroll, .waitingForWiFi, .freeAppSpaceLocalWarning]
    }
    
    func clear() {
        foloversArray.removeAll()
        progresForOperation.removeAll()
        homeCardsObjects.removeAll()
        deletedCards.removeAll()
    }
    
    // MARK: registration view
    
    func addViewForNotification(view: CardsManagerViewProtocol) {
        
        if foloversArray.index(where: { $0.isEqual(object: view) }) == nil {
            foloversArray.append(view)
        }
        
        let keys = progresForOperation.keys
        for key in keys {
            let progress = progresForOperation[key]
            view.startOperationWith(type: key, allOperations: progress?.allOperations, completedOperations: progress?.completedOperations)
        }
    }
    
    func removeViewForNotification(view: CardsManagerViewProtocol) {
        if let index = foloversArray.index(where: { $0.isEqual(object: view) }) {
            foloversArray.remove(at: index)
        }
        
        let keys = progresForOperation.keys
        for key in keys {
            view.stopOperationWithType(type: key)
        }
    }
    
    private func setProgressForOperation(operation: OperationType, allOperations: Int?, completedOperations: Int?) {
        var progress = progresForOperation[operation]
        if (progress == nil) {
            progress = Progress()
        }
        progress!.allOperations = allOperations
        progress!.completedOperations = completedOperations
        progresForOperation[operation] = progress
    }
    
    func setPercentProgressForOperation(operation: OperationType, percent: Float, object: Item?) {
        if let progress = progresForOperation[operation] {
            progress.percentProgress = percent
            progress.lastObject = object
            progresForOperation[operation] = progress
        }
    }
    
    // MARK: sending operation to registred subviews
    func startOperatonsForCardsResponses(cardsResponses: [HomeCardResponse]) {
        let sortedArray = cardsResponses.sorted { obj1, obj2 -> Bool in
            obj1.order < obj2.order
        }
        homeCardsObjects.removeAll()
        homeCardsObjects.append(contentsOf: sortedArray)
        
        /// to test launchCampaign
//        let q = HomeCardResponse()
//        q.type = .launchCampaign
//        homeCardsObjects.append(q)
        
        homeCardsObjects = homeCardsObjects.filter {
            if let type = $0.getOperationType() {                
                return !deletedCards.contains(type)
            }
            return false
        }
        
        showHomeCards()
    }
    
    private func showHomeCards() {
        DispatchQueue.main.async {
            for notificationView in self.foloversArray {
                notificationView.startOperationsWith(serverObjects: self.homeCardsObjects)
            }
        }
    }
    
    func startOperationWith(type: OperationType, allOperations: Int? = nil, completedOperations: Int? = nil) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?) {
        DispatchQueue.toMain {
            print("operation is started: \(type.rawValue)")
            if (!self.canShowPopUpByDepends(type: type)) {
                return
            }
            if self.deletedCards.contains(type) {
                return
            }
            
            self.hidePopUpsByDepends(type: type)
            
            self.setProgressForOperationWith(type: type, allOperations: allOperations ?? 0, completedOperations: completedOperations ?? 0)
            
            for notificationView in self.foloversArray {
                notificationView.startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
            }
        }
        
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ) {
        setProgressForOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int) {
        guard ReachabilityService.shared.isReachable else {
            return
        }
        
        hidePopUpsByDepends(type: type)
        
        DispatchQueue.toMain {
            self.setProgressForOperation(operation: type, allOperations: allOperations, completedOperations: completedOperations)
            
            for notificationView in self.foloversArray {
                notificationView.setProgressForOperationWith(type: type,
                                                             object: object,
                                                             allOperations: allOperations,
                                                             completedOperations: completedOperations)
            }
        }
    }
    
    func setProgress(ratio: Float, operationType: OperationType, object: WrapData?) {
        setPercentProgressForOperation(operation: operationType, percent: ratio, object: object)
        for notificationView in self.foloversArray {
            notificationView.setProgress(ratio: ratio, for: operationType, object: object)
        }
    }
    
    func updateAllProgressesInCardsForView(view: CardsManagerViewProtocol){
        for operation in progresForOperation.keys {
            if let progress = progresForOperation[operation] {
                
                if let object = progress.lastObject, let percent = progress.percentProgress {
                    view.setProgress(ratio: percent, for: operation, object: object)
                }
                
                if let allOperation = progress.allOperations, let completedOperations = progress.completedOperations {
                    view.setProgressForOperationWith(type: operation,
                                                     object: nil,
                                                     allOperations: allOperation,
                                                     completedOperations: completedOperations)
                }
            }
        }
    }

    func stopOperationWith(type: OperationType) {
        DispatchQueue.toMain {
            self.progresForOperation[type] = nil
            print("operation stopped ", type.rawValue)
            for notificationView in self.foloversArray {
                notificationView.stopOperationWithType(type: type)
            }
        }
    }
    
    func stopOperationWith(type: OperationType, serverObject: HomeCardResponse?) {
        guard let object = serverObject else {
            stopOperationWith(type: type)
            return
        }
        
        DispatchQueue.main.async {
            self.progresForOperation[type] = nil
            for notificationView in self.foloversArray {
                notificationView.stopOperationWithType(type: type, serverObject: object)
            }
        }
    }
    
    func manuallyDeleteCardsByType(type: OperationType, homeCardResponse: HomeCardResponse? = nil) {
        var typeForInsert: OperationType? = nil
        if let response = homeCardResponse, !response.actionable {
            typeForInsert = type
        }else if type == .freeAppSpaceLocalWarning {
            typeForInsert = type
        }
        
        if let typeForInsert = typeForInsert, !deletedCards.contains(typeForInsert) {
            deletedCards.insert(type)
        }
        
        stopOperationWith(type: type, serverObject: homeCardResponse)
    }
    
    func stopAllOperations() {
        for operation in progresForOperation.keys {
            stopOperationWith(type: operation)
        }
    }
    
    func hidePopUpsByDepends(type: OperationType) {
        switch type {
        case .upload:
            stopOperationWith(type: .waitingForWiFi)
        default:
            break
        }
    }
    
    func canShowPopUpByDepends(type: OperationType) -> Bool {
        switch type {
        case .freeAppSpaceLocalWarning:
            let operations: [OperationType] = [.upload]
            for operation in operations {
                if progresForOperation[operation] != nil {
                    return false
                }
            }
        default:
            break
        }
        
        return true
    }
    
    // MARK: views for operations
    
    func checkIsThisOperationStartedByDevice(operation: OperationType) -> Bool {
        return cardsThatStartedByDevice.contains(operation)
    }
    
    private func serverOperationFor(type: OperationType) -> HomeCardResponse? {
        for serverObject in homeCardsObjects {
            if serverObject.getOperationType() == type {
                return serverObject
            }
        }
        return nil
    }
    
    class func cardViewForOperaion(type: OperationType) -> BaseCardView {
        let serverObject = CardsManager.default.serverOperationFor(type: type)
        let cardView: BaseCardView
        debugLog("cardViewForOperaion: type is \(type.rawValue)")
        
        switch type {
        case .freeAppSpaceCloudWarning, .freeAppSpaceLocalWarning, .emptyStorage:
            let popUp = StorageCard.initFromNib()
            popUp.configurateWithType(viewType: type)
            cardView = popUp
            case .download, .upload, .sharedWithMeUpload:
            let popUp = ProgressCard.initFromNib()
            popUp.configurateWithType(viewType: type)
            cardView = popUp
        case .prepareQuickScroll:
            cardView = PrepareQuickScroll.initFromNib()
        case .waitingForWiFi:
            cardView = WaitingForWiFiPopUp.initFromNib()
        }
        
        /// seems like duplicated logic "set(object:".
        /// needs to drop before regression tests.
        cardView.set(object: serverObject)
        
        return cardView
    }
    
}
