//
//  TopBarSortingView.swift
//  Depo
//
//  Created by Alex Developer on 03.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

protocol TopBarSortingViewDelegate: class {
    func sortingTypeChanged(sortType: MoreActionsConfig.SortRullesType)
}

final class TopBarSortingView: UICollectionReusableView, NibInit {
    
    @IBOutlet weak var sortLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.topBarSortSubviewSortByLabel
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var sortByButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            
            newValue.setImage(UIImage(named: "sortingArrow"), for: .normal)
            newValue.adjustsFontSizeToFitWidth()
            
            newValue.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.titleLabel?.textColor = ColorConstants.Text.labelTitle
            
            newValue.forceImageToRightSide()
        }
    }
    
    private let floatingContainerWidth: CGFloat = 192
    
    private var currentSortOption: MoreActionsConfig.SortRullesType = .AlphaBetricAZ {
        willSet {
            sortByButton.setTitle("\(newValue.description) ", for: .normal)
        }
    }
    private var availableSortOptions = [MoreActionsConfig.SortRullesType]()
    
    weak var delegate: TopBarSortingViewDelegate?

    
    func setupSortingMenu(sortTypes: [MoreActionsConfig.SortRullesType] = [.AlphaBetricAZ, .AlphaBetricZA, .lastModifiedTimeNewOld, .lastModifiedTimeOldNew, .Largest, .Smallest], defaultSortType: MoreActionsConfig.SortRullesType) {
        availableSortOptions = sortTypes
        currentSortOption = defaultSortType
    }
    
    @IBAction func sortByAction(_ sender: Any) {
        guard !availableSortOptions.isEmpty else {
            assertionFailure("by this point available sort options should be filled")
            return
        }
        let sortingTable = GridListTopBarSortingTableView(style: .plain)
        sortingTable.actionDelegate = self
        let titles = availableSortOptions.map{ $0.description }
        let selectedSort: Int = availableSortOptions.index(of: currentSortOption) ?? 0
        
        sortingTable.setup(withTitles: titles, selectedIndex: selectedSort)

        let popUpHeight = sortingTable.defaultCellHeight * CGFloat(titles.count)
        
        let floatingVC = FloatingContainerVC.createContainerVC(withContentView: sortingTable,
                                                               sourceView: sortByButton.imageView!,
                                                               popOverSize: CGSize(width: floatingContainerWidth,
                                                                                   height: popUpHeight))
        
        RouterVC().defaultTopController?.present(floatingVC, animated: true, completion: nil)
    }
    
}

extension TopBarSortingView: GridListTopBarSortingTableViewDelegate {
    func gridListTopBarSortingTableView(_ gridListTopBarSortingTableView: GridListTopBarSortingTableView, didSelectItemAtIndex index: IndexPath) {
        guard index.row < availableSortOptions.count else {
            return
        }
        currentSortOption = availableSortOptions[index.row]

        delegate?.sortingTypeChanged(sortType: currentSortOption)
        gridListTopBarSortingTableView.dismiss(animated: true, completion: nil)
    }
}
