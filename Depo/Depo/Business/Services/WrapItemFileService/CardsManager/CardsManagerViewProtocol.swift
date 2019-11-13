//
//  WrapItemOperationViewProtocol.swift
//  Depo_LifeTech
//
//  Created by Oleg on 27.09.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol CardsManagerViewProtocol {
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?)
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?)
    
    func startOperationsWith(serverObjects: [HomeCardResponse])
        
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int)
    
    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData?)
    
    func stopOperationWithType(type: OperationType)
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse)
    
    func isEqual(object: CardsManagerViewProtocol) -> Bool
    
    func addNotPermittedCardViewTypes(types: [OperationType])
    
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount)
    
    var isEnable: Bool { get set }
}
