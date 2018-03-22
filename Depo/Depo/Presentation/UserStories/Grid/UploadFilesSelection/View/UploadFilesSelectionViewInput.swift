//
//  UploadFilesSelectionUploadFilesSelectionViewInput.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol UploadFilesSelectionViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    
    var currentVC: UIViewController { get }
}
