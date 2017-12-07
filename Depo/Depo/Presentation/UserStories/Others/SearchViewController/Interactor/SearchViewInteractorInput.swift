//
//  SearchViewInteractorInput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewInteractorInput {
    func viewIsReady()
    func searchItems(by searchText: String, sortBy: SortType, sortOrder: SortOrder)
    func needShowNoFileView() -> Bool
    func getSuggetion(text: String)
}
