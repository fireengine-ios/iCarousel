//
//  TrashBinInteractor.swift
//  Depo
//
//  Created by Andrei Novikau on 1/9/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol TrashBinInteractorDelegate: class {
    func didLoad(items: [Item])
    func failedLoadItemsPage(error: Error)
}

final class TrashBinInteractor: MoreFilesActionsInteractor {

    private let itemsPageSize = 50

    private weak var delegate: TrashBinInteractorDelegate?

    private lazy var hiddenService = HiddenService()

    private var itemsPage = 0

    var sortedRule: SortedRules = .timeUp

    private var itemsTask: URLSessionTask?

    private var itemsIsFinishLoad = false

    //MARK: - Init

    required init(delegate: TrashBinInteractorDelegate?) {
        self.delegate = delegate
    }

    deinit {
        itemsTask?.cancel()
    }

    //MARK: - Public methods

    func reloadData(completion: @escaping VoidHandler) {
        reloadItems(completion: completion)
    }

    func reloadItems(completion: @escaping VoidHandler) {
        itemsPage = 0
        itemsTask?.cancel()
        itemsTask = nil
        itemsIsFinishLoad = false
        loadNextItemsPage(completion: completion)
    }

    func loadNextItemsPage(completion: VoidHandler? = nil) {
        guard itemsTask == nil, !itemsIsFinishLoad else {
            return
        }
        
        itemsTask = hiddenService.trashedList(sortBy: sortedRule.sortingRules, sortOrder: sortedRule.sortOder, page: itemsPage, size: itemsPageSize, folderOnly: false, handler: {  [weak self] result in
            guard let self = self else {
                return
            }
            
            self.itemsTask = nil
            
            switch result {
            case .success(let response):
                self.itemsPage += 1
                self.delegate?.didLoad(items: response.fileList)
                
                if response.fileList.isEmpty {
                    self.itemsIsFinishLoad = true
                }
            case .failed(let error):
                self.delegate?.failedLoadItemsPage(error: error)
            }
            
            completion?()
        })
    }    
}
