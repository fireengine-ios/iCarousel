//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderInteractor.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotosOrderInteractor: CreateStoryPhotosOrderInteractorInput {
    
    weak var output: CreateStoryPhotosOrderInteractorOutput!
    
    private lazy var fileService = WrapItemFileService()
    private lazy var createStoryService = CreateStoryService(transIdLogging: true)
    
    var story: PhotoStory?
    
    var isRequestStarted = false
    private var syncAttempts = 0
    private let maxAttempts = 3
    
    func viewIsReady() {
        if story != nil {
            output.showStory(story: story!)
        }
    }
    
    func onNextButton(array: [Item]) {
        if isRequestStarted {
            return
        }
        
        guard let story = story else {
            return
        }
        
        if story.music == nil {
            output.audioNotSelectedError()
            return
        }
        
        if array.first(where: {$0.isLocalItem}) != nil {
            replaceLocalItems()
        } else {
            createStory(with: array)
        }
    }
    
    private func createStory(with items: [Item]) {
        guard let story = story else {
            return
        }
        
        output.startCreateStory()
        
        story.storyPhotos.removeAll()
        story.storyPhotos.append(contentsOf: items)
        //TODO: creation story on server
        isRequestStarted = true
        if let parameter = story.photoStoryRequestParameter() {
            let t = CreateStoryPreview(name: parameter.title,
                                       imageuuid: parameter.imageUUids,
                                       musicUUID: parameter.audioUuid,
                                       musicId: parameter.musicId)
            
            createStoryService.getPreview(preview: t, success: { [weak self] responce in
                if let `self` = self {
                    self.isRequestStarted = false
                    DispatchQueue.main.async {
                        self.output.goToStoryPreview(story: story, responce: responce)
                    }
                }
                }, fail: { [weak self] fail in
                    if let `self` = self {
                        self.isRequestStarted = false
                        DispatchQueue.main.async {
                            self.output.createdStoryFailed(with: fail)
                        }
                    }
            })
        } else {
            isRequestStarted = false
        }
    }
    
    func onMusicSelection() {
        guard let story_ = story else {
            return
        }
        output.goToAudioSelection(story: story_)
    }
    
    private func sync(items: [Item]) {
        syncAttempts += 1
        
        fileService.syncItemsIfNeeded(items, success: { [weak self] in
            self?.replaceLocalItems()
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.createdStoryFailed(with: error)
            }
        }, syncOperations: { [weak self] syncOperations in
            if syncOperations != nil, let output = self?.output as? BaseAsyncOperationInteractorOutput {
                output.startCancelableAsync(cancel: { [weak self] in
                    UploadService.default.cancelSyncToUseOperations()
                    DispatchQueue.main.async {
                        self?.output.createdStoryFailed(with: ErrorResponse.string(TextConstants.createStoryCancel))
                    }
                })
            }
        })
    }
    
    private func replaceLocalItems() {
        guard let story = story else {
            return
        }
        
        let localItems = story.storyPhotos.filter { $0.isLocalItem }
        let trimmedLocalIds = localItems.map { $0.getTrimmedLocalID() }
        MediaItemOperationsService.shared.getRemotesMediaItems(trimmedLocalIds: trimmedLocalIds) { [weak self] mediaItems in
            guard let self = self else {
                return
            }
            
            localItems.forEach { localItem in
                if let mediaItem = mediaItems.first(where: { $0.trimmedLocalFileID == localItem.getTrimmedLocalID() }),
                    let index = story.storyPhotos.firstIndex(of: localItem) {
                    let remoteItem = WrapData(mediaItem: mediaItem)
                    story.storyPhotos[index] = remoteItem
                }
            }
            
            if story.storyPhotos.first(where: { $0.isLocalItem }) == nil {
               self.onNextButton(array: story.storyPhotos)
            } else if self.syncAttempts < self.maxAttempts {
                self.sync(items: story.storyPhotos)
            } else {
                DispatchQueue.main.async {
                    self.output.createdStoryFailed(with: ErrorResponse.string(TextConstants.createStoryCancel))
                    self.syncAttempts = 0
                }
            }
        }
    }
}
