//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractor.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderInteractor: NSObject, LBAlbumLikePreviewSliderInteractorInput, ItemOperationManagerViewProtocol {

    weak var output: LBAlbumLikePreviewSliderInteractorOutput!

    let dataStorage = LBAlbumLikePreviewSliderDataStorage()

    //MARK: - Interactor Input
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    var currentItems: [SliderItem] {
        set {
            dataStorage.currentItems = newValue
        }
        get {
            return dataStorage.currentItems.sorted(by: { item1, item2 -> Bool in
                if let type1 = item1.type?.rawValue, let type2 = item2.type?.rawValue {
                    return type1 < type2
                }
                return false
            })
        }
    }

    func requestAllItems() {
        currentItems = []
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "GetMyStreamData")
        
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        
        let albumService = AlbumService(requestSize: 4)
        albumService.allAlbums(sortBy: .date, sortOrder: .desc, success: { [weak self] albums in
            DispatchQueue.main.async {
                self?.dataStorage.addNew(item: SliderItem(withAlbumItems: albums))
                group.leave()
            }
        }, fail: { [weak self] in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                group.leave()
            }
        })

        let storiesService = StoryService(requestSize: 4)
        storiesService.allStories(success: { [weak self] stories in
            DispatchQueue.main.async {
                self?.dataStorage.addNew(item: SliderItem(withStoriesItems: stories))
                group.leave()
            }
        }, fail: { [weak self] in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                group.leave()
            }
        })
        
        faceImageAllowed { [weak self] result in
            if result == true {
                let peopleService = PeopleService()
                peopleService.getPeopleList(param: PeopleParameters(), success: { [weak self] response in
                    if let people = response as? PeopleServiceResponse {
                        self?.dataStorage.addNew(item: SliderItem(withPeopleItems: people.list))
                    }
                    DispatchQueue.main.async {
                        group.leave()
                    }
                    
                    }, fail: { [weak self] error in
                        DispatchQueue.main.async {
                            self?.output.operationFailed()
                            group.leave()
                        }
                })
                
                let thingsService = ThingsService()
                thingsService.getThingsList(param: ThingsParameters(), success: { [weak self] response in
                    if let things = response as? ThingsServiceResponse {
                        self?.dataStorage.addNew(item: SliderItem(withThingItems: things.list))
                    }
                    DispatchQueue.main.async {
                        group.leave()
                    }
                    }, fail: { [weak self] error in
                        DispatchQueue.main.async {
                            self?.output.operationFailed()
                            group.leave()
                        }
                })
                
                let placesService = PlacesService()
                placesService.getPlacesList(param: PlacesParameters(), success: { [weak self] response in
                    if let places = response as? PlacesServiceResponse {
                        self?.dataStorage.addNew(item: SliderItem(withPlaceItems: places.list))
                    }
                    DispatchQueue.main.async {
                        group.leave()
                    }
                    }, fail: { [weak self] error in
                        DispatchQueue.main.async {
                            self?.output.operationFailed()
                            group.leave()
                        }
                })
            } else {
                DispatchQueue.main.async {
                    group.leave()
                    group.leave()
                    group.leave()
                }
            }
        }
        
        group.notify(queue: queue) { [weak self] in
             DispatchQueue.main.async {
                if let `self` = self {
                    self.output.operationSuccessed(withItems: self.currentItems)
                }
            }
        }
    }
    
    fileprivate func faceImageAllowed(completion: @escaping (_ result: Bool) -> Void) {
        let accountService = AccountService()
        accountService.faceImageAllowed(success: { response in
            if let response = response as? FaceImageAllowedResponse, let allowed = response.allowed {
                completion(allowed)
            } else {
                completion(false)
            }
            
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.operationFailed()
                completion(false)
            }
        })
    }
    
    //Protocol ItemOperationManagerViewProtocol
    
    func newAlbumCreated() {
        requestAllItems()
    }
    
    func newStoryCreated() {
        requestAllItems()
    }
    
    func albumsDeleted(albums: [AlbumItem]) {
        requestAllItems()
    }
    
    func deleteStories(items: [Item]) {
        requestAllItems()
    }
    
    func filesAddedToAlbum() {
        requestAllItems()
    }

    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? LBAlbumLikePreviewSliderInteractor {
            return compairedView == self
        }
        return false
    }
}
