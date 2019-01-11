//
//  AnalyzeHistoryViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 10/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AnalyzeHistoryViewController: ViewController, NibInit {
    
    @IBOutlet var designer: AnalyzeHistoryDesigner!
    @IBOutlet var displayManager: AnalyzeHistoryDisplayManager!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newAnalysisButton: BlueButtonWithMediumWhiteText!
    @IBOutlet weak var newAnalysisButtonBottonConstraint: NSLayoutConstraint!
    
    private let dataSource = AnalyzeHistoryDataSourceForCollectionView()
    
    private let refresher = UIRefreshControl()
    private var page = 0
    
    private let instapickService: InstapickService = factory.resolve()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    private func configure() {
        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        collectionView.contentInset.bottom = newAnalysisButtonBottonConstraint.constant + newAnalysisButton.bounds.height + 8
        
        refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    // MARK: - Actions
    
    @IBAction private func newAnalysisAction(_ sender: Any) {
        
    }
    
    // MARK: - Functions
    
    @objc private func reloadData() {
        reloadCards()
        page = 0
        dataSource.isPaginationDidEnd = false
        loadNextHistoryPage()
    }
    
    private func stopRefresher() {
        if refresher.isRefreshing {
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
            }
        }
    }
    
    private func reloadCards() {
        instapickService.getAnalysisCount { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let analysisCount):
                self.dataSource.reloadCards(with: analysisCount)
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadNextHistoryPage() {
        instapickService.getAnalyzeHistory(offset: page, limit: 20) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let history):
                DispatchQueue.main.async {
                    self.dataSource.appendHistoryItems(history)
                    self.page += 1
                
                    if self.dataSource.isEmpty {
                        self.displayManager.applyConfiguration(.empty)
                    } else if self.displayManager.configuration == .empty {
                        self.displayManager.applyConfiguration(.initial)
                    }
                }
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - AnalyzeHistoryDataSourceDelegate

extension AnalyzeHistoryViewController: AnalyzeHistoryDataSourceDelegate {
    func needLoadNextHistoryPage() {
        loadNextHistoryPage()
    }
    
    func onLongPressInCell() {
    
    }
    
    func onPurchase() {
        
    }
    
    func onSeeDetailsForAnanyze(_ analyze: InstapickAnalyze) {
        
    }
}
