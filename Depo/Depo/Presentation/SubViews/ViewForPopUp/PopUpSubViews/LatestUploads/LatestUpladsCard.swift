//
//  LatestUpladsCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class LatestUpladsCard: BaseCardView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewRecentActivitiesButton: UIButton!
    @IBOutlet weak var viewAllPhotosButton: UIButton!
    @IBOutlet weak var collectionViewH: NSLayoutConstraint!
    
    var collectionViewDataSource = [WrapData]()
    
    let numberOfСellInRow: Int = 7
    let minSeparatorSize: CGFloat = 2
    var collectionViewW: CGFloat = 0
    
    override func configurateView() {
        super.configurateView()
        
        title.font = UIFont.TurkcellSaturaBolFont(size: 18)
        title.textColor = ColorConstants.darkText
        title.text = TextConstants.homeLatestUploadsCardTitle
        
        subTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
        subTitle.textColor = ColorConstants.textGrayColor
        subTitle.text = TextConstants.homeLatestUploadsCardSubTitle
        
        viewRecentActivitiesButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        viewRecentActivitiesButton.setTitle(TextConstants.homeLatestUploadsCardRecentActivitiesButton, for: .normal)
        viewRecentActivitiesButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        viewRecentActivitiesButton.adjustsFontSizeToFitWidth()
        
        viewAllPhotosButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        viewAllPhotosButton.setTitle(TextConstants.homeLatestUploadsCardAllPhotosButtn, for: .normal)
        viewAllPhotosButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        viewAllPhotosButton.adjustsFontSizeToFitWidth()
        
        collectionView.register(nibCell: LatestUploadCardCell.self)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if collectionViewW != collectionView.frame.size.width {
            collectionViewW = collectionView.frame.size.width
            collectionView.layoutSubviews()
            collectionView.reloadData()
            
            let cellWidth = calculateLinearDimensionsForCell()
            
            let calculatedHeightOfCollectionView : CGFloat
            if moreThatOneRow() {
                calculatedHeightOfCollectionView = cellWidth * 2 + minSeparatorSize
            } else {
                calculatedHeightOfCollectionView = cellWidth
            }
            
            calculatedH = (frame.size.height - collectionView.frame.size.height) + calculatedHeightOfCollectionView
            collectionViewH.constant = calculatedHeightOfCollectionView
            layoutIfNeeded()
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        if let details = object?.details {
            set(details: details)
        }
    }
    
    private func moreThatOneRow() -> Bool {
        return collectionViewDataSource.count > numberOfСellInRow
    }
    
    private func set(details object: JSON) {
        collectionViewDataSource.removeAll()
        if let arrayOfJsons = object.array {
            for itemObject in arrayOfJsons {
                let searchItem = SearchItemResponse(withJSON: itemObject)
                let item = WrapData(remote: searchItem)
                collectionViewDataSource.append(item)
                if collectionViewDataSource.count == numberOfСellInRow * 2 {
                    break
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    override func viewWillShow() {
        super.viewWillShow()
        
        collectionView.reloadData()
    }
    
    @IBAction func onViewRecentActivitiesButton() {
        let router = RouterVC()
        let controller = router.vcActivityTimeline
        router.pushViewController(viewController: controller)
    }

    
    @IBAction func onViewAllPhotosButton() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationPhotosScreen), object: nil, userInfo: nil)
    }
    
    @IBAction func onCloseButton() {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .latestUploads, serverObject: cardObject)
    }
}

extension LatestUpladsCard: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: LatestUploadCardCell.self, for: indexPath)
        let object = collectionViewDataSource[indexPath.row]
        cell.setImage(image: object)
        return cell
    }
}

extension LatestUpladsCard: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minSeparatorSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minSeparatorSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: calculateLinearDimensionsForCell(), height: calculateLinearDimensionsForCell())
    }
    
    private func calculateLinearDimensionsForCell() -> CGFloat {
        let w = collectionView.frame.size.width
        let cellW = (w - minSeparatorSize * CGFloat(numberOfСellInRow) + minSeparatorSize) / CGFloat(numberOfСellInRow)
        return cellW
    }
}
