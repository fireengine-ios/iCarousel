//
//  AutoSyncAutoSyncViewInput.swift
//  Depo
//
//  Created by Oleg on 16/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol AutoSyncViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    func preperedCellsModels(models:[AutoSyncModel])
}
