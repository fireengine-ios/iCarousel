//
//  SegmentedController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol SegmentedChildController: AnyObject {
    func setTitle(_ title: String)
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
}
extension SegmentedChildController where Self: UIViewController {

    private var parentVC: SegmentedController? {
        return parent as? SegmentedController
    }

    func setTitle(_ title: String) {
        let navItem = parentVC?.navigationItem ?? navigationItem
        navItem.title = title
    }
    
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        let navItem = parentVC?.navigationItem ?? navigationItem
        navItem.leftBarButtonItems = nil
        navItem.setLeftBarButtonItems(items, animated: animated)
    }

    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        let navItem = parentVC?.navigationItem ?? navigationItem
        navItem.rightBarButtonItems = nil
        navItem.setRightBarButtonItems(items, animated: animated)
    }
}

//protocol SegmentedControllerDelegate: AnyObject {
//    func segmentedControllerEndEditMode()
//}

class SegmentedController: BaseViewController, NibInit {
    
    enum Alignment {
        case center
        case adjustToWidth
    }
    
    class func initWithControllers(_ controllers: [UIViewController], alignment: Alignment) -> SegmentedController {
        let controller = SegmentedController.initFromNib()
        controller.setup(with: controllers, alignment: alignment)
        return controller
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.delegate = self
            newValue.dataSource = self
            newValue.showsHorizontalScrollIndicator = false
            newValue.register(UINib(nibName: CollectionViewCellsIdsConstant.cellForAllFilesType, bundle: nil),
                              forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForAllFilesType)
        }
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var segmentedControlContainer: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl! {
        willSet {
            newValue.tintColor = ColorConstants.darkBlueColor
            newValue.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.TurkcellSaturaRegFont(size: 14)],
                                            for: .normal)
        }
    }
    
    private(set) var viewControllers = [BaseViewController]()
    private var alignment: Alignment = .center
    private var selectedCellIndexPath: IndexPath? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var currentController: UIViewController {
        return viewControllers[safe: segmentedControl.selectedSegmentIndex] ?? UIViewController()
    }
    
    private(set) var selectedIndex = 0
    var startIndex = 0
    
    //    weak var delegate: SegmentedControllerDelegate?
    
    //    private lazy var cancelSelectionButton = UIBarButtonItem(
    //        title: TextConstants.cancelSelectionButtonTitle,
    //        font: .TurkcellSaturaDemFont(size: 19.0),
    //        target: self,
    //        selector: #selector(onCancelSelectionButton))
    
    //    @objc private func onCancelSelectionButton() {
    //        delegate?.segmentedControllerEndEditMode()
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        needToShowTabBar = true
        setupSegmentedControl()
        setupAlignment()
        setCollectionView()
    }
    
    private func setCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        
        guard !viewControllers.isEmpty else {
            assertionFailure()
            return
        }
        
        for (index, controller) in viewControllers.enumerated() {
            if let image = controller.segmentImage?.image {
                image.accessibilityLabel = controller.segmentImage!.accessibilityLabel
                segmentedControl.insertSegment(with: image, at: index, animated: false)
            } else {
                segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
            }
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        segmentedControl.selectedSegmentIndex = startIndex
        setupSelectedController(viewControllers[segmentedControl.selectedSegmentIndex])
    }
    
    func setup(with controllers: [UIViewController], alignment: Alignment) {
        guard !controllers.isEmpty, let controllers = controllers as? [BaseViewController] else {
            assertionFailure()
            return
        }
        viewControllers = controllers
        self.alignment = alignment
    }
    
    private func setupAlignment() {
        switch alignment {
        case .center:
            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: segmentedControlContainer.leadingAnchor, constant: 16).activate()
            segmentedControlContainer.trailingAnchor.constraint(greaterThanOrEqualTo: segmentedControl.trailingAnchor, constant: 16).activate()
        case .adjustToWidth:
            segmentedControl.leadingAnchor.constraint(equalTo: segmentedControlContainer.leadingAnchor, constant: 16).activate()
            segmentedControlContainer.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor, constant: 16).activate()
        }
    }
    
    func switchSegment(to index: Int) {
        if segmentedControl.numberOfSegments > index, segmentedControl.selectedSegmentIndex != index {
            segmentedControl.selectedSegmentIndex = index
            segmentDidChange(segmentedControl)
        }
    }
    
    @IBAction private func segmentDidChange(_ sender: UISegmentedControl) {
        let newIndex = sender.selectedSegmentIndex
        guard newIndex < viewControllers.count else {
            assertionFailure()
            return
        }
        
        guard canSwitchSegment(from: selectedIndex, to: newIndex) else {
            sender.selectedSegmentIndex = selectedIndex
            return
        }
        
        selectedIndex = sender.selectedSegmentIndex
        
        children.forEach { $0.removeFromParentVC() }
        setupSelectedController(viewControllers[selectedIndex])
    }
    
    func canSwitchSegment(from oldIndex: Int, to newIndex: Int) -> Bool {
        return true
    }
    
    private func setupSelectedController(_ controller: BaseViewController) {
        controller.navigationBarHidden = self.navigationBarHidden
        add(childController: controller)
        floatingButtonsArray = controller.floatingButtonsArray
    }
    
    private func add(childController: UIViewController) {
        addChild(childController)
        childController.view.frame = containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func switchAllFilesCategory(to index: Int) {
        if AllFilesType.allCases.count >= index, selectedIndex != index {
            guard index < viewControllers.count else {
                assertionFailure()
                return
            }
            
            selectedIndex = index
            children.forEach { $0.removeFromParentVC() }
            setupSelectedController(viewControllers[selectedIndex])
        }
    }
}


//extension SegmentedController: PhotoVideoDataSourceDelegate {
//    func selectedModeDidChange(_ selectingMode: Bool) {
//        if selectingMode {
//            navigationItem.leftBarButtonItem = cancelSelectionButton
//        } else {
//            navigationItem.leftBarButtonItem = nil
//        }
//    }
//}

extension UIViewController {
    
    func removeFromParentVC() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension SegmentedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AllFilesType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForAllFilesType,
                                                         for: indexPath) as? AllFilesTypeCollectionViewCell {
            let types = AllFilesType.allCases
            cell.configure(with: types[indexPath.row])
            cell.setSelection(with: types[indexPath.row], isSelected: indexPath == selectedCellIndexPath)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension SegmentedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? AllFilesTypeCollectionViewCell
        if indexPath == selectedCellIndexPath {
            selectedCellIndexPath = nil
            switchAllFilesCategory(to: 0)
        } else {
            cell?.setSelection(with: AllFilesType.allCases[indexPath.row], isSelected: true)
            selectedCellIndexPath = indexPath
            switchAllFilesCategory(to: indexPath.row + 1)
        }
    }
}
