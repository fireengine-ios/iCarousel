//
//  FaceImageAddNameInteractorInput.swift
//  Depo
//
//  Created by Harhun Brothers on 08.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImageAddNameInteractorInput {
    func getSearchPeople(_ text: String)
    func setNewNameForPeople(_ text: String, personId: Int64)
    func mergePeople(_ currentPerson: Item, otherPerson: Item)
}
