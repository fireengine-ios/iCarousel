//
//  LatestUpladsCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import SwiftyJSON

class LatestUpladsCard: BaseView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewRecentActivitiesButton: UIButton!
    @IBOutlet weak var viewAllPhotosButton: UIButton!
    var collectionViewDataSource = [WrapData]()
    
    let numberOfcellInRow: CGFloat = 7
    let minSeparatorSize: CGFloat = 2
    
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
        
    }

    @IBAction func onViewAllPhotosButton(){
        
    }
    
    //MARK: UICollectionView Delegate
    
    func calculateLinearDimensionsForCell() -> CGFloat{
        let w = collectionView.frame.size.width
        return (w - minSeparatorSize*numberOfcellInRow + minSeparatorSize)/numberOfcellInRow
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth:CGFloat) -> CGFloat{
        return calculateLinearDimensionsForCell()
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat{
        return HomeViewTopView.getHeight()
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
