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
    case sync                       = "Sync"
    case download                   = "Download"
    case prepareToAutoSync          = "prepareToAutoSync"
    case prepareQuickScroll         = "prepareQuickScroll"
//    case preparePhotosQuickScroll   = "preparePhotosQuickScroll"
//    case prepareVideosQuickScroll   = "prepareVideosQuickScroll"
    case autoUploadIsOff            = "autoUploadIsOff"
    case waitingForWiFi             = "waitingForWiFi"
    
    case freeAppSpace               = "FreeAppSpace"
    case freeAppSpaceLocalWarning   = "freeAppSpaceLocalWarning"
    case freeAppSpaceCloudWarning   = "freeAppSpaceCloudWarning"
    case emptyStorage               = "emptyStorage"
    
    case contactBacupEmpty          = "contactBacupEmpty"
    case contactBacupOld            = "contactBacupOld"
    case collage                    = "collage"
    case albumCard                  = "albumCard"
    case latestUploads              = "latestUploads"
    case stylizedPhoto              = "stylizedPhoto"
    case movieCard                  = "movieCard"
    case animationCard              = "animation"
    
    case launchCampaign             = "launchCampaign"
    case premium                    = "premium"
    case instaPick                  = "instaPick"
    case tbMatik                    = "TBMATIC"
    case campaignCard               = "CAMPAIGN"
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
        return [.upload, .sync, .download, .prepareToAutoSync, .prepareQuickScroll, .autoUploadIsOff, .waitingForWiFi, .freeAppSpace, .freeAppSpaceLocalWarning]
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

    func startPremiumCard() {
        DispatchQueue.main.async {
            for notificationView in self.foloversArray {
                notificationView.startOperationWith(type: .premium, allOperations: 0, completedOperations: 0)
            }
        }
    }
    
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount) {
        DispatchQueue.main.async {
            for notificationView in self.foloversArray {
                notificationView.configureInstaPick(with: analysisStatus)
            }
        }
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ) {
        setProgressForOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int) {
        hidePopUpsByDepends(type: type)
        
        DispatchQueue.toMain {
            self.setProgressForOperation(operation: type, allOperations: allOperations, completedOperations: completedOperations)
            
            for notificationView in self.foloversArray {
                
                if let obj = object {
                    notificationView.setProgressForOperationWith(type: type, object: obj, allOperations: allOperations, completedOperations: completedOperations)
                } else {
                    notificationView.setProgressForOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
                }
                
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
            if let progress = progresForOperation[operation]{
                
                if let object = progress.lastObject, let percent = progress.percentProgress {
                    view.setProgress(ratio: percent, for: operation, object: object)
                }
                
                if let allOperation = progress.allOperations, let completedOperations = progress.completedOperations {
                    view.setProgressForOperationWith(type: operation, allOperations: allOperation, completedOperations: completedOperations)
                }
            }
        }
    }

    func stopOperationWithType(type: OperationType) {
        DispatchQueue.toMain {
            self.progresForOperation[type] = nil
            print("operation stopped ", type.rawValue)
            for notificationView in self.foloversArray {
                notificationView.stopOperationWithType(type: type)
            }
        }
    }
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse?) {
        guard let object = serverObject else {
            stopOperationWithType(type: type)
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
        }else if type == .freeAppSpaceLocalWarning || type == .freeAppSpace {
            typeForInsert = type
        }
        
        if let typeForInsert = typeForInsert, !deletedCards.contains(typeForInsert) {
            deletedCards.insert(type)
        }
        
        stopOperationWithType(type: type, serverObject: homeCardResponse)
    }
    
    func stopAllOperations() {
        for operation in progresForOperation.keys {
            stopOperationWithType(type: operation)
        }
    }
    
    func hidePopUpsByDepends(type: OperationType) {
        switch type {
        case .sync:
            stopOperationWithType(type: .prepareToAutoSync)
            stopOperationWithType(type: .waitingForWiFi)
            stopOperationWithType(type: .freeAppSpaceLocalWarning)
            stopOperationWithType(type: .freeAppSpace)
            stopOperationWithType(type: .autoUploadIsOff)
        case .upload:
//            stopOperationWithType(type: .prepareToAutoSync)
            stopOperationWithType(type: .waitingForWiFi)
            stopOperationWithType(type: .freeAppSpaceLocalWarning)
            stopOperationWithType(type: .freeAppSpace)
        case .freeAppSpace:
            stopOperationWithType(type: .emptyStorage)
        case .prepareToAutoSync:
            stopOperationWithType(type: .waitingForWiFi)
            stopOperationWithType(type: .autoUploadIsOff)
        case .waitingForWiFi:
            stopOperationWithType(type: .autoUploadIsOff)
            stopOperationWithType(type: .prepareToAutoSync)
        case .autoUploadIsOff:
            stopOperationWithType(type: .prepareToAutoSync)
            stopOperationWithType(type: .sync)
        default:
            break
        }
    }
    
    func canShowPopUpByDepends(type: OperationType) -> Bool {
        switch type {
        case .freeAppSpace, .freeAppSpaceLocalWarning:
            let operations: [OperationType] = [.sync, .upload]
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
            if type == .freeAppSpaceLocalWarning, serverObject.getOperationType() == .freeAppSpace {
                return serverObject
            }
            
            if serverObject.getOperationType() == type {
                return serverObject
            }
        }
        return nil
    }
    
    class func popUpViewForOperaion(type: OperationType) -> BaseView {
        let serverObject = CardsManager.default.serverOperationFor(type: type)
        let cardView: BaseView
        
        switch type {
        case .freeAppSpace:
            let view = FreeUpSpacePopUp.initFromNib()
            view.configurateWithType(viewType: type)
            cardView = view
        case .freeAppSpaceCloudWarning, .freeAppSpaceLocalWarning, .emptyStorage:
            let popUp = StorageCard.initFromNib()
            popUp.configurateWithType(viewType: type)
            cardView = popUp
        case .download, .sync, .upload:
            let popUp = ProgressPopUp.initFromNib()
            popUp.configurateWithType(viewType: type)
            cardView = popUp
        case .prepareToAutoSync:
            cardView = PrepareToAutoSync.initFromNib()
        case .prepareQuickScroll:
            cardView = PrepareQuickScroll.initFromNib()
//        case .preparePhotosQuickScroll:
//            cardView = PrepareQuickScroll.initFromNib()
//        case .prepareVideosQuickScroll:
//            cardView = PrepareQuickScroll.initFromNib()
        case .autoUploadIsOff:
            cardView = AutoUploadIsOffPopUp.initFromNib()
        case .waitingForWiFi:
            cardView = WaitingForWiFiPopUp.initFromNib()
        case .contactBacupEmpty:
            cardView = ContactBackupEmpty.initFromNib()
        case .contactBacupOld:
            cardView = ContactBackupOld.initFromNib()
        case .collage:
            cardView = CollageCard.initFromNib()
        case .albumCard:
            cardView = AlbumCard.initFromNib()
        case .latestUploads:
            cardView = LatestUpladsCard.initFromNib()
        case .stylizedPhoto:
            cardView = FilterPhotoCard.initFromNib()
        case .movieCard:
            cardView = MovieCard.initFromNib()
        case .animationCard:
            cardView = AnimationCard.initFromNib()
        case .launchCampaign:
            cardView = LaunchCampaignCard.initFromNib()
        case .premium:
            let popUp = PremiumInfoCard.initFromNib()
            popUp.configurateWithType(viewType: .premium)
            cardView = popUp
        case .instaPick:
            cardView = InstaPickCard.initFromNib()
        case .tbMatik:
            cardView = TBMatikCard.initFromNib()
        case .campaignCard:
            cardView = CampaignCard.initFromNib()
        }
        
        /// seems like duplicated logic "set(object:".
        /// needs to drop before regression tests.
        cardView.set(object: serverObject)
        
        return cardView
    }
    
}
