//
//  DuplicatedContactsViewController.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class DuplicatedContactsViewController: BaseViewController, DuplicatedContactsViewInput {

    var output: DuplicatedContactsViewOutput!
    var analyzeResponse = ContactSync.AnalyzeResponse(contactsToMerge: [ContactSync.AnalyzedContact](),
                                                      contactsToDelete: [ContactSync.AnalyzedContact]())
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        setTitle(withString: TextConstants.duplicatedContacts)
        
        output.viewIsReady()
    }
    
    // MARK: Actions
    
    // MARK: DuplicatedContactsViewInput
    
}
