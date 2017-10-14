//
//  BaseFilesGreedInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol BaseFilesGreedInteractorOutput: class, BaseAsyncOperationInteractorOutput {
    
    func getContentWithSuccess()
    
    func getContentWithFail(errorString: String)
    
    func serviceAreNotAvalible()
    
    var sortedRule: SortedRules { get set }
    
    var filters: [GeneralFilesFiltrationType] {get set}
    
}
