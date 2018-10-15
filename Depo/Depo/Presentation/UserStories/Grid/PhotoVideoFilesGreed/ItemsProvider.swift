//
//  ItemsProvider.swift
//  Depo
//
//  Created by Aleksandr on 10/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

typealias ItemsCallback = (_ items: [WrapData])->Void

class ItemsProvider {///Maybe create also something like ItemsDownloader
    
    static let shared = ItemsProvider()
    
    private var allRemoteItems = [WrapData]()
    ///var previousRemoteItems
    
    var databasePageSize: Int = NumericConstants.numberOfLocalItemsOnPage
//    private var currentDataBasePage: Int = 0

    //private let quickSearchService
    

    
    func updateItems() { ///QuickScroll API?
        
    }
    
    func reloadItems(callback: ItemsCallback) { ///Will be inactive after quickScroll API implementation

    }
    ///dlya photo And Videos
    func getNextItems(newFieldValue: FieldValue?, callback: ItemsCallback) {
        
    }
    
    private func getItems(pageNum: Int, pageSize: Int, callback: ItemsCallback) {
//        currentSearchAPIPage += 1
    }
    
    
    
}
