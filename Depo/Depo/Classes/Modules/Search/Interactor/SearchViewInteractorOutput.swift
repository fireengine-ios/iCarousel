//
//  SearchViewInteractorOutput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewInteractorOutput: class {
    
    func endSearchRequestWith(text: String)
    
    func getContentWithSuccess()
    
    func successWithSuggestList(list: [SuggestionObject])
    
    func failedSearch()
}
