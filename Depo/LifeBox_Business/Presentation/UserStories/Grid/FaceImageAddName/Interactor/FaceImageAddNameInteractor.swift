//
//  FaceImageAddNameInteractor.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageAddNameInteractor: BaseFilesGreedInteractor {
    
    private let peopleService = PeopleService()
        
    private var currentName: String?
            
    override func viewIsReady() {
        output.getContentWithSuccess(items: [])
    }
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        output.getContentWithSuccessEnd()
    }
    
}

// MARK: - FaceImageAddNameInteractorInput

extension FaceImageAddNameInteractor: FaceImageAddNameInteractorInput {
    
    func getSearchPeople(_ text: String) {
        guard isUpdating == false else {
            return
        }
        
        output.startAsyncOperation()
        
        if let service = remoteItems as? PeopleItemsService {
            service.searchPeople(text: text, success: { [weak self] items in
                self?.output.getContentWithSuccess(items: items)
                }, fail: { [weak self]  in
                    self?.output.getContentWithSuccess(items: [])
            })
        }
    }
    
    func setNewNameForPeople(_ text: String, personId: Int64) {
        guard isUpdating == false else {
            return
        }
        
        currentName = text
        
        peopleService.changePeopleName(personId: personId, name: text, success: { [weak self] response in
            self?.output.asyncOperationSuccess()
            if let output = self?.output as? FaceImageAddNameInteractorOutput,
                let name = self?.currentName {
                output.didChangeName(name)
            }
            
            }, fail: { [weak self] error in
                self?.output.asyncOperationFail(errorMessage: error.description)
        })
    }
    
    func mergePeople(_ currentPerson: Item, otherPerson: Item) {
        guard isUpdating == false,
        let currentPersonId = currentPerson.id,
        let otherPersonId = otherPerson.id else {
            return
        }

        peopleService.mergePeople(personId: otherPersonId, targetPersonId: currentPersonId, success: { [weak self] response in
            self?.output.asyncOperationSuccess()

            if let output = self?.output as? FaceImageAddNameInteractorOutput {
                output.didMergePeople()
            }
        }, fail: { [weak self] error in
            self?.output.asyncOperationFail(errorMessage: error.description)
        })
    }
}
