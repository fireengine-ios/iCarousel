//
//  FreeAppSpaceFreeAppSpaceInteractor.swift
//  Depo
//
//  Created by Oleg on 14/11/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FreeAppSpaceInteractor: BaseFilesGreedInteractor {
    
    var isDeleteRequestRunning = false
    
    private lazy var freeAppSpace = FreeAppSpace.session
    private lazy var wrapFileService = WrapItemFileService()
    
    private let fileService = FileService()
    
    func onDeleteSelectedItems(selectedItems: [WrapData]) {
        if isDeleteRequestRunning {
            return
        }
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.FreeUpSpace(count: selectedItems.count))
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .freeUpSpace)
        isDeleteRequestRunning = true
        checkAndDelete(items: selectedItems)
    }
    
    private func checkAndDelete(items: [WrapData]) {
        let localCoreDataObjectIds = items.compactMap { $0.coreDataObjectId }
        
        MediaItemOperationsService.shared.mediaItemsByIDs(ids: localCoreDataObjectIds) { [weak self] mediaItems in
            guard let self = self else {
                return
            }
            assert(items.count == mediaItems.count)

            let relatedRemotesUuids = mediaItems
                .compactMap { $0.relatedRemotes.allObjects as? [MediaItem] }
                .flatMap { $0 }
                .compactMap { $0.uuid }
            
            self.deleteRemotesAndLocals(relatedRemotesUuids: relatedRemotesUuids,
                       localCoreDataObjectIds: localCoreDataObjectIds)

        }
        
    }
    
    private func deleteRemotesAndLocals(relatedRemotesUuids: [String], localCoreDataObjectIds: [NSManagedObjectID]) {
        fileService.details(uuids: relatedRemotesUuids, success: { [weak self] updatedRemoteItems in
            
            let avalableRemoteItems = updatedRemoteItems.filter { $0.status.isTranscoded }
            
            let associatedRemoteItemsToDelete = avalableRemoteItems.filter { avalableItem in
                relatedRemotesUuids.contains(where: {
                    $0 == avalableItem.uuid
                })
            }
            
            let remoteUuidsToDelete = relatedRemotesUuids.filter { relatedRemoteUUID in
                !associatedRemoteItemsToDelete.contains(where: {
                    $0.uuid == relatedRemoteUUID
                })
            }
            
            MediaItemOperationsService.shared.deleteRemoteEntities(uuids: remoteUuidsToDelete, completion: { [weak self] _ in
                
                self?.findLocalItemsToDelete(by: associatedRemoteItemsToDelete.compactMap { $0.uuid }, originalLocalItemsToDeleteIDs: localCoreDataObjectIds, completion: { [weak self] localItemsToDelete in
                    
                    self?.deleteLocalItems(localItemsToDelete: localItemsToDelete)
                    
                })
            })
            }, fail: { [weak self] error in
                UIApplication.showErrorAlert(message: error.description)
                
                guard let self = self else {
                    return
                }
                
                self.isDeleteRequestRunning = false
                if let output = self.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        output.canceled()
                    }
                } else {
                    assertionFailure()
                }
        })
    }
    
    private func findLocalItemsToDelete(by assosiatedRemotesUUIDS: [String], originalLocalItemsToDeleteIDs: [NSManagedObjectID], completion: @escaping WrapObjectsCallBack) {
        MediaItemOperationsService.shared.mediaItemsByIDs(ids: originalLocalItemsToDeleteIDs) { mediaItems in
            assert(originalLocalItemsToDeleteIDs.count == mediaItems.count)
            
            let localMediaItemsForDeletion = mediaItems.filter{ localMediaItem in
                guard let relatedRemotes = localMediaItem.relatedRemotes.allObjects as? [MediaItem] else {
                    return false
                }
                for relatedRemote in relatedRemotes {
                    if assosiatedRemotesUUIDS.contains(where: { $0 == relatedRemote.uuid }) {
                        return true
                    }
                }
                return false
            }
            completion(localMediaItemsForDeletion.map { WrapData(mediaItem: $0) })
        }
        
    }
    
    private func deleteLocalItems(localItemsToDelete: [WrapData]) {
        wrapFileService.deleteLocalFiles(deleteFiles: localItemsToDelete, success: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.isDeleteRequestRunning = false
            
            if let presenter = self.output as? FreeAppSpacePresenter {
                DispatchQueue.main.async {
                    presenter.onItemDeleted(count: localItemsToDelete.count)
                    if FreeAppSpace.session.getDuplicatesObjects().isEmpty {
                        
                        CardsManager.default.stopOperationWith(type: .freeAppSpace)
                        CardsManager.default.stopOperationWith(type: .freeAppSpaceLocalWarning)
                    }
                    presenter.goBack()
                }
            }
            }, fail: { [weak self] error in
                guard let `self` = self else {
                    return
                }
                
                self.isDeleteRequestRunning = false
                if let presenter = self.output as? FreeAppSpacePresenter {
                    DispatchQueue.main.async {
                        presenter.canceled()
                    }
                }
        })
    }
    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.FreeUpSpaceScreen())
        analyticsManager.logScreen(screen: .freeAppSpace)
        analyticsManager.trackDimentionsEveryClickGA(screen: .freeAppSpace)
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        if let remoteItems = remoteItems as? FreeAppService {
            remoteItems.clear()
        }
        super.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
    }
    
}
