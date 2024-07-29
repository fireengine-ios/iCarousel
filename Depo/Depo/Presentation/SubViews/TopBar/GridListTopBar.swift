//
//  GridListTopBar.swift
//  Depo
//
//  Created by Aleksandr on 9/7/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol GridListTopBarDelegate: AnyObject {
    
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType)
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType)
    func representationChanged(viewType: MoreActionsConfig.ViewType)
    func onMoreButton()
    
}

class GridListTopBar: ViewController {
    
    @IBOutlet fileprivate weak var sortByButton: UIButton! {
        didSet {
            sortByButton.setTitle(TextConstants.sortby, for: .normal)
            sortByButton.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet fileprivate weak var gridListButton: UIButton!
    @IBOutlet public weak var moreButton: UIButton!
    @IBOutlet private weak var middleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet fileprivate weak var segmentFilter: UISegmentedControl!
    
    @IBOutlet private weak var centerYConstraint: NSLayoutConstraint!

    var currentConfig: GridListTopBarConfig?
    
    let floatingContainerWidth: CGFloat = 236
    
    weak var delegate: GridListTopBarDelegate?
    
    var selectedIndex = -1
    
    class func initFromXib() -> GridListTopBar {
        let view = GridListTopBar(nibName: "GridListTopBar", bundle: nil)
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInitialState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }
    
    private func setupInitialState() {
        sortByButton.titleLabel?.font = UIFont.appFont(.medium, size: 16)
        sortByButton.titleLabel?.textColor = UIColor.darkGray        
        segmentFilter.tintColor = ColorConstants.darkBlueColor
        sortByButton.forceImageToRightSide()
    }
    
    func setupWithConfig(config: GridListTopBarConfig, centeredContent: Bool = false) {
        currentConfig = config
        setupSortingView(withTypes: config.availableSortTypes,
                         defaultType: config.defaultSortType)
        setupGridListViewType(withDefault: config.defaultGridListViewtype)
        
        if config.availableFilter {
            setupFilterSegmentView(defaultState: config.defaultFilterState)
        }
        
        gridListButton.isHidden = !config.showGridListButton
        moreButton.isHidden = !config.showMoreButton
        
        if centeredContent {
            centerYConstraint.constant = 0
        }
        
        if let middleText = config.middleText {
            middleLabel.isHidden = false
            middleLabel.text = middleText
        }
    }
    
    func setSorting(enabled: Bool) {
        sortByButton.isHidden = !enabled
    }
    
    private func setupSortingView(withTypes types: [MoreActionsConfig.SortRullesType],
                                  defaultType: MoreActionsConfig.SortRullesType) {
        sortByButton.isHidden = types.isEmpty
    }
    
    private func setupFilterSegmentView(defaultState: MoreActionsConfig.MoreActionsFileType) {
        segmentFilter.isHidden = false
        segmentFilter.isEnabled = true
        segmentFilter.setTitle(TextConstants.topBarVideosFilter, forSegmentAt: 1)
        segmentFilter.setTitle(TextConstants.topBarPhotosFilter, forSegmentAt: 0)
        
        switch defaultState {
        case .Photo:
            segmentFilter.selectedSegmentIndex = 0
        case .Video:
            segmentFilter.selectedSegmentIndex = 1
        default:
            segmentFilter.selectedSegmentIndex = 0
        }
        
        segmentFilter.addTarget(self, action: #selector(self.segmentControlValueChanged(sender:)),
                                for: .valueChanged)
    }
    
    private func setupGridListViewType(withDefault defaultType: MoreActionsConfig.ViewType) {
        switch defaultType {
        case .List:
            gridListButton.isSelected = true
        default:
            gridListButton.isSelected = false
        }
    }
    
    @objc func segmentControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            delegate?.filterChanged(filter: .Photo)
            sender.selectedSegmentIndex = 1//
        default:
            delegate?.filterChanged(filter: .Video)
            sender.selectedSegmentIndex = 0//
        }
        
    }
    
    // MARK: - Actions

    @IBAction func sortAction(_ sender: Any) {
        guard let unwrapedConfig = currentConfig else {
            return
        }
        let sortingTable = GridListTopBarSortingTableView()
        sortingTable.actionDelegate = self
        let titles = unwrapedConfig.availableSortTypes.map({ $0.description })
        let images = unwrapedConfig.availableSortTypes.map({ $0.sortImage })
        var selectedSort: Int
        if (selectedIndex != -1) {
            selectedSort = selectedIndex
        } else {
            selectedSort = currentConfig?.availableSortTypes.firstIndex(of: unwrapedConfig.defaultSortType) ?? 0
        }
        sortingTable.setup(withTitles: titles, images: images, selectedIndex: selectedSort)
        sortingTable.presentAsDrawer()
    }
    
    @IBAction func gridListAction(_ sender: Any) {
        gridListButton.isSelected = !gridListButton.isSelected
        let type: MoreActionsConfig.ViewType = gridListButton.isSelected ? .Grid : .List
        delegate?.representationChanged(viewType: type)
    }
    
    @IBAction func onMoreButton(_ sender: Any) {
        delegate?.onMoreButton()
    }
    
}

extension GridListTopBar: GridListTopBarSortingTableViewDelegate {
    func gridListTopBarSortingTableView(_ gridListTopBarSortingTableView: GridListTopBarSortingTableView, didSelectItemAtIndex index: IndexPath) {
        guard let unwrapedConfig = currentConfig, index.row < unwrapedConfig.availableSortTypes.count else {
            return
        }
        selectedIndex = index.row
        delegate?.sortingRuleChanged(rule: unwrapedConfig.availableSortTypes[index.row])
        gridListTopBarSortingTableView.dismiss(animated: true, completion: nil)
    }
}
