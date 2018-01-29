//
//  LatestUpladsCard.swift
//  Depo
//
//  Created by Oleg on 27.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class LatestUpladsCard: BaseView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewRecentActivitiesButton: UIButton!
    @IBOutlet weak var viewAllPhotosButton: UIButton!
    var collectionViewDataSource = [Any]()
    
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
    
    @IBAction func onViewRecentActivitiesButton(){
        
    }

    @IBAction func onViewAllPhotosButton(){
        
    }
    
    //MARK: UICollectionView Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth:CGFloat) -> CGFloat{
        return 40
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat{
        return HomeViewTopView.getHeight()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: LatestUploadCardCell.self, for: indexPath)
        return cell
    }
    
}
