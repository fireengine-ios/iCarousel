//
//  LatestUpladsCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class LatestUpladsCard: BaseView {

    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewRecentActivitiesButton: UIButton!
    @IBOutlet weak var viewAllPhotosButton: UIButton!
    var collectionViewDataSource = [WrapData]()
    
    let numberOfcellInRow: CGFloat = 7
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
        
        viewAllPhotosButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        viewAllPhotosButton.setTitle(TextConstants.homeLatestUploadsCardAllPhotosButtn, for: .normal)
        viewAllPhotosButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        
        collectionView.register(nibCell: LatestUploadCardCell.self)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if collectionViewW != collectionView.frame.size.width{
            collectionViewW = collectionView.frame.size.width
            collectionView.layoutSubviews()
            collectionView.reloadData()
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        if let details = object?.details {
            set(details: details)
        }
    }
    
    
    private func set(details object: JSON) {
        if let array = object.array {
            for itemObject in array{
                let searchItem = SearchItemResponse(withJSON: itemObject)
                let item = WrapData(remote: searchItem)
                item.syncStatus = .synced
                item.isLocalItem = false
                collectionViewDataSource.append(item)
            }
        }
        collectionView.reloadData()
    }
    
    @IBAction func onViewRecentActivitiesButton(){
        let router = RouterVC()
        let controller = router.vcActivityTimeline
        router.pushViewController(viewController: controller)
    }

    @IBAction func onViewAllPhotosButton(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationPhotosScreen), object: nil, userInfo: nil)
    }
    
    @IBAction func onCloseButton(){
        CardsManager.default.stopOperationWithType(type: .latestUploads)
    }
    
}


//MARK: UICollectionView Delegate
extension LatestUpladsCard: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func calculateLinearDimensionsForCell() -> CGFloat{
        let w = collectionView.frame.size.width
        let cellW = (w - minSeparatorSize*numberOfcellInRow + minSeparatorSize)/numberOfcellInRow
        return cellW
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: calculateLinearDimensionsForCell(), height: calculateLinearDimensionsForCell())
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: LatestUploadCardCell.self, for: indexPath)
        let object = collectionViewDataSource[indexPath.row]
        cell.setImage(image: object)
        return cell
    }
    
    //-----
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minSeparatorSize
    }
    
    //|||||
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minSeparatorSize
    }
    
}
