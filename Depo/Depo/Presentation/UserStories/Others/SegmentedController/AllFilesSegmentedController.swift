//
//  AllFilesSegmentedController.swift
//  Depo
//
//  Created by Andrei Novikau on 17.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AllFilesSegmentedController: SegmentedController, HeaderContainingViewControllerChild {

    //MARK: -IBOutlet
    @IBOutlet private weak var segmentStackView: UIStackView!
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.delegate = self
            newValue.dataSource = self
            newValue.showsHorizontalScrollIndicator = false
            newValue.register(UINib(nibName: CollectionViewCellsIdsConstant.cellForAllFilesType, bundle: nil),
                              forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForAllFilesType)
            newValue.backgroundColor = AppColor.filesBackground.color
        }
    }
    
    //MARK: -Properties
    private var segmentConfigured = false
    private var selectedSharedItemsSegment = 0
    private var selectedCellIndexPath: [IndexPath] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let sharedSegmentsView: SharedItemsSegmentView = {
        let view = SharedItemsSegmentView.initFromNib()
        view.isHidden = true
        return view
    }()
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHidden = true
        setCollectionView()
        setSegmentedControl()

        setDefaultNavigationHeaderActions()
        ItemOperationManager.default.startUpdateView(view: self)
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override static func initWithControllers(_ controllers: [UIViewController], alignment: Alignment) -> AllFilesSegmentedController {
        let controller = AllFilesSegmentedController.initFromNib()
        controller.setup(with: controllers, alignment: alignment)
        return controller
    }
    
    //MARK: -Helpers
    private func setCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
    }
    
    private func setSegmentedControl() {
        segmentStackView.addArrangedSubview(sharedSegmentsView)
        sharedSegmentsView.delegate = self
    }
    
    private func switchAllFilesCategory(to index: Int) {
        if AllFilesType.allCases.count >= index, selectedIndex != index {
            guard index < viewControllers.count else {
                assertionFailure()
                return
            }
            
            if !segmentConfigured {
                sharedSegmentsView.sharedSegmentControl.addUnderlineForSelectedSegment()
                segmentConfigured = true
            }
            
            if !(index == AllFilesType.allCases.firstIndex(of: .sharedWithMe)) && !(index == AllFilesType.allCases.firstIndex(of: .sharedByMe)) {
                selectedSharedItemsSegment = 0
                sharedSegmentsView.reset()
            }
            
            selectedIndex = index
            sharedSegmentsView.isHidden = (index != AllFilesType.allCases.firstIndex(of: .sharedWithMe)) && (index != AllFilesType.allCases.firstIndex(of: .sharedByMe))
            children.forEach { $0.removeFromParentVC() }
            setupSelectedController(viewControllers[selectedIndex])
        }
    }
}

//MARK: -UICollectionViewDataSource
extension AllFilesSegmentedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AllFilesType.getSegments().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForAllFilesType,
                                                         for: indexPath) as? AllFilesTypeCollectionViewCell {
            let types = AllFilesType.getSegments()
            cell.configure(with: types[indexPath.row])
            cell.setSelection(with: types[indexPath.row], isSelected: selectedCellIndexPath.contains(indexPath))
            return cell
        }
        return UICollectionViewCell()
    }
}

//MARK: -UICollectionViewDelegate
extension AllFilesSegmentedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ///LB-1430
        let cell = collectionView.cellForItem(at: indexPath) as? AllFilesTypeCollectionViewCell
        if selectedCellIndexPath.isEmpty {
            cell?.setSelection(with: AllFilesType.allCases[indexPath.row], isSelected: true)
            selectedCellIndexPath = [indexPath]
            switchAllFilesCategory(to: indexPath.row)
        } else if selectedCellIndexPath.contains(indexPath) {
            if selectedCellIndexPath.count == 1 {
                selectedCellIndexPath = []
                if let index = AllFilesType.allCases.firstIndex(of: .allFiles) {
                    switchAllFilesCategory(to: index)
                    sharedSegmentsView.reset()
                }
            } else {
                selectedCellIndexPath.remove(indexPath)
                if let indexPath = selectedCellIndexPath.first {
                    switchAllFilesCategory(to: indexPath.row)
                }
            }
        } else if !selectedCellIndexPath.contains(indexPath) {
            if indexPath.row == AllFilesType.allCases.firstIndex(of: .favorites) ||
                indexPath.row == AllFilesType.allCases.firstIndex(of: .sharedWithMe) ||
                selectedCellIndexPath.contains(where: {$0.row == AllFilesType.allCases.firstIndex(of: .favorites)}) ||
                selectedCellIndexPath.contains(where: {$0.row == AllFilesType.allCases.firstIndex(of: .sharedWithMe)}) {
                selectedCellIndexPath = [indexPath]
                switchAllFilesCategory(to: indexPath.row)
            } else {
                selectedCellIndexPath.append(indexPath)
                if let index = AllFilesType.allCases.firstIndex(of: .documentsAndMusic) {
                    switchAllFilesCategory(to: index)
                }
            }
        }
    }
}

//MARK: -SharedItemsSegmentViewDelegate
extension AllFilesSegmentedController: SharedItemsSegmentViewDelegate {
    func sharedSegmentChanged(to index: Int) {
        if index != selectedSharedItemsSegment {
            selectedSharedItemsSegment = index
            switch index {
            case SharedItemsSegment.allCases.firstIndex(of: .sharedWithMe):
                if let index = AllFilesType.allCases.firstIndex(of: .sharedWithMe) {
                    switchAllFilesCategory(to: index)
                }
            case SharedItemsSegment.allCases.firstIndex(of: .sharedByMe):
                if let index = AllFilesType.allCases.firstIndex(of: .sharedByMe) {
                    switchAllFilesCategory(to: index)
                }
            default:
                break
            }
        }
    }
}

//MARK: -ItemOperationManagerViewProtocol
extension AllFilesSegmentedController: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return self === object
    }
    
    func allFilesSectionChange(to index: Int, shareType: SharedItemsSegment?) {
        switchAllFilesCategory(to: index)
        selectedCellIndexPath = [IndexPath(item: index, section: 0)]
        
        if let shareType = shareType, let index = SharedItemsSegment.allCases.firstIndex(of: shareType) {
            sharedSegmentsView.sharedSegmentControl.selectedSegmentIndex = index
            sharedSegmentsView.sharedSegmentControl.changeUnderlinePosition()
            sharedSegmentChanged(to: index)
        }
    }
}
