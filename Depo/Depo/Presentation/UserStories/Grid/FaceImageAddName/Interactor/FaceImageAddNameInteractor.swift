//
//  FaceImageAddNameInteractor.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class FaceImageAddNameInteractor: BaseFilesGreedInteractor, FaceImageAddNameInteractorInput {
    
    private let peopleService = PeopleService()
    
    private var currentName: String?
        
    override func viewIsReady() {
        output.getContentWithSuccess(items: [])
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        output.getContentWithSuccessEnd()
    }
    
    //MARK: - FaceImageAddNameInteractorInput

    func getSearchPeople(_ text: String) {
        guard isUpdating == false else {
            return
        }
        
        if let service = remoteItems as? PeopleItemsService {
            service.searchPeople(text: text, success: { [weak self] (items) in
                self?.output.getContentWithSuccess(items: items)
                }, fail: { [weak self] in
                    self?.output.getContentWithSuccess(items: [])
            })
        }
    }
    
    func setNewNameForPeople(_ text: String, personId: Int64) {
        guard isUpdating == false else {
            return
        }
        
        currentName = text
        
        peopleService.changePeopleName(personId: personId, name: text, success: { [weak self] (response) in
            self?.output.asyncOperationSucces()
            if let output = self?.output as? FaceImageAddNameInteractorOutput,
                let name = self?.currentName {
                output.didChangeName(name)
            }
        }) { [weak self] (error) in
            self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
        }
    }
    
    func mergePeople(_ id: Int64, personId: Int64) {
        guard isUpdating == false else {
            return
        }
        
        peopleService.mergePeople(personId: id, targetPersonId: personId, success: { [weak self] (response) in
            self?.output.asyncOperationSucces()

            if let output = self?.output as? FaceImageAddNameInteractorOutput {
                output.didMergePeople()
            }
        }) { [weak self] (error) in
            self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
        }
    }
}

