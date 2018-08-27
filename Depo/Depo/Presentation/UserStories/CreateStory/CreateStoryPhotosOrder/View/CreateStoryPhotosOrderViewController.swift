//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderViewController.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryPhotosOrderViewController: BaseViewController, CreateStoryPhotosOrderViewInput, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CollectionViewStoryReorderViewDelegate, ErrorPresenter {

    var output: CreateStoryPhotosOrderViewOutput!
    
    private var fileDataSource = FilesDataSource()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewData = [Item]()
    
    weak var selectedCell: PhotosOrderCollectionViewCell?
    

    // MARK: Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        navigationItem.rightBarButtonItem?.isEnabled = true
        setTitle(withString: TextConstants.createStory, andSubTitle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let nib = UINib(nibName: CollectionViewCellsIdsConstant.photosOrderCell, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.photosOrderCell)
        
        let headerNib = UINib(nibName: CollectionViewSuplementaryConstants.collectionViewStoryReorderView, bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewStoryReorderView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        collectionView.addGestureRecognizer(longPressGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: TextConstants.createStoryPhotosOrderNextButton,
            target: self,
            selector: #selector(onNextButton))
        
        output.viewIsReady()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            setSelectionForCellSelectedBy(gesture: gesture, selection: true)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
            setSelectionForCellSelectedBy(gesture: gesture, selection: false)
        default:
            collectionView.cancelInteractiveMovement()
            setSelectionForCellSelectedBy(gesture: gesture, selection: false)
        }
    }
    
    func setSelectionForCellSelectedBy(gesture: UILongPressGestureRecognizer, selection: Bool) {
        if (!selection) {
            
        }
        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
            if (selectedCell != nil) {
                selectedCell?.setSelection(selection: false)
            }
            return
        }
        
        let cell = collectionView.cellForItem(at: selectedIndexPath)
        if let cell_ = cell as? PhotosOrderCollectionViewCell {
            if (selection) {
                selectedCell = cell_
            }
            cell_.setSelection(selection: selection)
        }
    }
    
    
    @objc func onNextButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        output.onNextButton(array: collectionViewData)
    }


    // MARK: CreateStoryPhotosOrderViewInput
    func setupInitialState() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
    // MARK: Input
    
    func showStory(story: PhotoStory) {
        collectionViewData.removeAll()
        collectionViewData.append(contentsOf: story.storyPhotos)
        collectionView.reloadData()
    }
    
    func getNavigationControllet() -> UINavigationController? {
        return navigationController
    }
    
    
    // MARK: UICollectionView delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.collectionViewStoryReorderView, for: indexPath)
            if let header = headerView as? CollectionViewStoryReorderView {
                header.delegate = self
            }
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? PhotosOrderCollectionViewCell else {
            return
        }
        
        let object = collectionViewData[indexPath.row]
        cell.setPosition(position: indexPath.row + 1)
        fileDataSource.getImage(patch: object.patchToPreview) { [weak self] image in
            DispatchQueue.toMain {
                let contains = self?.collectionView.indexPathsForVisibleItems.contains(indexPath)
                if let value = contains, value == true {
                    cell.configurateWith(image: image)
                    return
                }
            }

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.photosOrderCell, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (collectionViewData.count == 0) {
            return
        }
        
        let file = collectionViewData[indexPath.row]
        fileDataSource.cancelImgeRequest(path: file.patchToPreview)
        
        guard let cell_ = cell as? PhotosOrderCollectionViewCell else {
            return
        }
        cell_.configurateWith(image: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset = NumericConstants.iPadGreedInset
        if (Device.isIpad) {
            inset = NumericConstants.iPhoneGreedInset
        }
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if (Device.isIpad) {
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
    
    //|||||
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if (Device.isIpad) {
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var countCellInLine: CGFloat = CGFloat(NumericConstants.creationStoryOrderingCountPhotosInLineiPhone)
        var inset = NumericConstants.iPadGreedInset
        var horizontalSpace = NumericConstants.iPhoneGreedHorizontalSpace
        
        if (Device.isIpad) {
            countCellInLine = CGFloat(NumericConstants.creationStoryOrderingCountPhotosInLineiPad)
            inset = NumericConstants.iPhoneGreedInset
            horizontalSpace = NumericConstants.iPadGreedHorizontalSpace
        }
        
        let screenSize = view.frame.size.width
        
        let cellW: CGFloat = (screenSize - 2 * inset - horizontalSpace * CGFloat(countCellInLine - 1)) / countCellInLine
        
        return CGSize(width: cellW, height: cellW)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.contentSize.width, height: 53.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let obj = collectionViewData[sourceIndexPath.row]
        collectionViewData.remove(at: sourceIndexPath.row)
        collectionViewData.insert(obj, at: destinationIndexPath.row)
        updateAllVisibleCell()
    }
    
    func updateAllVisibleCell() {
        let array = collectionView.visibleCells
        for cell in array {
            if let cell_ = cell as? PhotosOrderCollectionViewCell {
                let indexPath = collectionView.indexPath(for: cell)
                if let indexPath_ = indexPath {
                    cell_.setPosition(position: indexPath_.row + 1)
                }
            }
        }
    }
    
    // MARK: CollectionViewStoryReorderViewDelegate
    
    func goToSelectionMusick() {
        output.onMusicSelection()
    }
}
