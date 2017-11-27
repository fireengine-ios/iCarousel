//
//  WrapItemOperationViewProtocol.swift
//  Depo_LifeTech
//
//  Created by Oleg on 27.09.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol WrapItemOperationViewProtocol{
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?)
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int)
    
    func stopOperationWithType(type: OperationType)
    
    func isEqual(object: WrapItemOperationViewProtocol) -> Bool
    
    func addNotPermittedPopUpViewTypes(types: [OperationType])
    
}

