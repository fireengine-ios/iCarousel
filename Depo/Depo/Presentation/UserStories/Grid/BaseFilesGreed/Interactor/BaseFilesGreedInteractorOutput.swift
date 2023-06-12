//
//  BaseFilesGreedInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol BaseFilesGreedInteractorOutput: BaseAsyncOperationInteractorOutput {
    
    func getContentWithSuccess(items: [WrapData])
    
    func getContentWithSuccessEnd()
    
    func getContentWithSuccess(array: [[BaseDataSourceItem]])
    
    func getContentWithFail(errorString: String?)
    
    func serviceAreNotAvalible()
    
    var sortedRule: SortedRules { get set }
    
    var filters: [GeneralFilesFiltrationType] { get set }
    
    func createFileSuccess(fileUuid: String, fileName: String)
    
    func createFileFail(errorResponse: ErrorResponse)
    
}
