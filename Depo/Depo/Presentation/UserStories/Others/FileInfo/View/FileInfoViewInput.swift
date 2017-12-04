//
//  FileInfoFileInfoViewInput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol FileInfoViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */
    
    typealias Item = WrapData

    func startRenaming()
    
    func setObject(object: BaseDataSourceItem)
    
}
