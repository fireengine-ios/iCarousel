//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderViewController.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import iCarousel

class LBAlbumLikePreviewSliderViewController: UIViewController, LBAlbumLikePreviewSliderViewInput {

    @IBOutlet weak var carousel: iCarousel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var output: LBAlbumLikePreviewSliderViewOutput!
    
    class func initFromXIB() -> LBAlbumLikePreviewSliderViewController {
        return LBAlbumLikePreviewSliderViewController(nibName: "LBAlbumLikePreviewSliderViewController", bundle: nil)
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
        
    }

    
    @objc func labelTouchRecognition(sender: Any) {
        output.sliderTitlePressed()
    }
    
    
    // MARK: LBAlbumLikePreviewSliderViewInput
    
    func setupInitialState() {
        view.backgroundColor = UIColor.lrSkinTone
        
        carousel.type = .custom
        carousel.delegate = self
        carousel.dataSource = self
        carousel.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = UIColor.gray
        titleLabel.alpha = 0.5
        
        titleLabel.text = TextConstants.albumLikeSlidertitle
        
        
        titleLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.labelTouchRecognition(sender:)))
        titleLabel.addGestureRecognizer(tapGesture)
        
//        view.addGestureRecognizer(tapGesture)
    }
    
    func setupCarousel() {
        carousel.reloadData()
    }
    
    func refreshTableContent() { //reload
        
    }
    
}

extension LBAlbumLikePreviewSliderViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return output.currentItems.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let albumItem = output.currentItems[index]
        
        let cell = AlbumLikeCarousellCell.initFromXIB()
        cell.frame = CGRect(x: 0, y: 0, width: 90, height: 90 + 24)
        if let unwrapedItem = albumItem.preview {
            
            cell.setup(forItem: unwrapedItem, titleText: albumItem.name ?? "Unnamed")
        }

//        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        //CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: "TEST", withText: "Sorry, \n currenly in developming", okButtonText: "¯\\_(ツ)_/¯")
        output.onSelectAlbumAt(index: index)
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        let itemSpacing: CGFloat = 18 // 18/2
        return 90 + itemSpacing
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let totalItems = CGFloat(carousel.numberOfItems)
        let itemWidhWithSpacing = carousel.itemWidth
        let itemDesirableStart: CGFloat = 15 - 9//9 is item natural spacing
        
        let halfViewWidth = view.bounds.width/2 - itemDesirableStart
        let halfItemWidth = itemWidhWithSpacing/2
        let tempoItemSpaceShift = (halfViewWidth - halfItemWidth)
        
        
        let tempoOffset: CGFloat = carousel.scrollOffset * 2
        let itemShiftToTotalItems = tempoItemSpaceShift/(totalItems-1)
        let spacingShift = -tempoItemSpaceShift + itemShiftToTotalItems * tempoOffset
        
        let newOffset = carousel.itemWidth * offset + spacingShift
        
        return CATransform3DMakeTranslation( newOffset, 0, 1)
        
    }
}
