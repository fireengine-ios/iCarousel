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
    
    private let refresher = UIRefreshControl()
    private var page = 0
    private var allDataLoaded = false
    
    private let instapickService: InstapickService = factory.resolve()
    
    private var items = [Item]()
    
    //Temp
    private var analysisCount = AnalysisCount(left: 0, total: 0) {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            }
        }
    }
    private var left = 0
    private var total = 0
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    private func configure() {
        collectionView.register(nibCell: CollectionViewCellForInstapickPhoto.self)
        collectionView.register(nibCell: CollectionViewCellForInstapickAnalysis.self)
        collectionView.contentInset.bottom = newAnalysisButtonBottonConstraint.constant + newAnalysisButton.bounds.height + 8
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
        allDataLoaded = false
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
                self.analysisCount = analysisCount
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadNextHistoryPage() {
        
    }
}

// MARK: - UICollectionViewDataSource

extension AnalyzeHistoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return collectionView.dequeue(cell: CollectionViewCellForInstapickAnalysis.self, for: indexPath)
        } else {
            return collectionView.dequeue(cell: CollectionViewCellForInstapickPhoto.self, for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            (cell as? CollectionViewCellForInstapickAnalysis)?.setup(with: analysisCount)
            (cell as? CollectionViewCellForInstapickAnalysis)?.delegate = self
        } else {
            (cell as? CollectionViewCellForInstapickPhoto)?.setup(with: items[indexPath.item])
        }
        
        if allDataLoaded {
            return
        }
        
        let countRow: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        let isLastSection = numberOfSections(in: collectionView) - 1 == indexPath.section
        let isLastCell = countRow - 1 == indexPath.row
        
        if isLastSection, isLastCell {
            loadNextHistoryPage()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AnalyzeHistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 126)
        } else {
            return CGSize(width: 80, height: 108)
        }
    }
}

extension AnalyzeHistoryViewController: InstapickAnalysisCellDelegate {
    func onPurchase() {
        
    }
    
    func onSeeDetails() {
        
    }
    
    func canLongPress() -> Bool {
        return true
    }
    
    func onLongPress(cell: UICollectionViewCell) {
        
    }
}
