//
//  DataStorage.swift
//  Depo
//
//  Created by Aleksandr on 6/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class DataStorage {
    
    let numberOfModels = 4
    let titles = ["E-Mail", "GSM Number", "Password", "Re-Enter Password"]//TODO: LOCALISE!
    var models: [BaseCellModel] = []
    
    func getModels() -> [BaseCellModel] {
        if self.models.count == 0 {
            self.createInitialStateModels()
        }
        return models
    }
    
    func configurateModel(forIndex index: Int, withValue value: String) {
        let model = models[index]
        model.inputField = value
        debugPrint("models are ", self.models)
    }
    
    private func createInitialStateModels() {
        for i in 0..<numberOfModels {
            models.append(BaseCellModel(withTitle: titles[i]))
        }
    }
    
}
