//
//  SearchViewInput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewInput: class {
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool)
    func getCollectionViewWidth() -> CGFloat
    func endSearchRequestWith(text: String)
    func successWithSuggestList(list: [SuggestionObject])
    func scrollViewDidScroll(scrollView: UIScrollView)
    func dismissController()
    
    func showMusicBar()
}
