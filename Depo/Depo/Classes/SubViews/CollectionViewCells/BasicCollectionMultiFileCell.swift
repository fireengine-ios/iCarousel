//
//  BasicCollectionMultiFileCell.swift
//  Depo
//
//  Created by Aleksandr on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BasicCollectionMultiFileCellActionDelegate: class {
    func morebuttonGotPressed(sender: Any, itemModel: Item?)
}

class BasicCollectionMultiFileCell: BaseCollectionViewCell {
    
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var smallContentImageView: SelectionImageView!
    @IBOutlet weak var bigContentImageView: UIImageView!
    
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var smallCellSelectionView: UIImageView!
    
    @IBOutlet weak var bottomViewH: NSLayoutConstraint!
    @IBOutlet weak var smallContentImageViewW: NSLayoutConstraint!
    @IBOutlet weak var smallContentImageViewH: NSLayoutConstraint!
    @IBOutlet weak var leftSpaceForSmallmage: NSLayoutConstraint!
    
    @IBOutlet weak var smallSelectonView: UIView!
    @IBOutlet weak var bigSelectionView: UIView!
    @IBOutlet weak var topFavoritesStar: UIImageView!
    @IBOutlet weak var bottomFavoritesStar: UIImageView!
    
    
    override weak var delegate: LBCellsDelegate? {
        didSet{
            if let compatableValue = delegate as? BasicCollectionMultiFileCellActionDelegate {
                actionDelegate = compatableValue
            }
        }
    }
    
    weak var actionDelegate: BasicCollectionMultiFileCellActionDelegate?
    
    static let smallH: CGFloat                          = 37
    static let bigH: CGFloat                            = 65
    static let frameSize: CGFloat                       = 66
    
    static let smallContentImageViewWConst: CGFloat     = 20
    static let smallContentImageViewHConst: CGFloat     = 24
    static let smallContentImageViewBigSize: CGFloat    = 42
    
    static let leftSpaceBigCell: CGFloat                = 6
    static let leftSpaceSmallCell: CGFloat              = 14
    
    var itemModel: Item?
    
    func stopAnimation(){
        activity.stopAnimating()
    }
    
    override func setImage(image: UIImage?) {
        if (image != nil){
            isAlreadyConfigured = true
            if (isBigSize()){
                bigContentImageView.image = image
            }else{
                smallContentImageView.configured = true
                smallContentImageView.setImage(image: image)
                smallContentImageView.isHidden = false
                smallCellSelectionView.isHidden = true
                
            }
        }
        stopAnimation()
    }
    
    private func isBigSize() -> Bool{
        return frame.size.height > BasicCollectionMultiFileCell.frameSize
    }
    
    override func setImage(with url: URL) {
        UIImageView().sd_setImage(with: url, placeholderImage: nil, options: [.avoidAutoSetImage]) { (image, error, cacheType, url) in
            self.setImage(image: image)
        }
    }
    
    override func confireWithWrapperd(wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? Item else{
            return
        }
        
        if (isAlreadyConfigured){
            return
        }
        
        itemModel = wrappered
        
        fileNameLabel.text = wrappedObj.name
        activity.startAnimating()
        bigContentImageView.image = nil
        stopAnimation()
        bigContentImageView.image = WrapperedItemUtil.getPreviewImageForWrapperedObject(object: wrappered)
        if (isBigSize()){
            smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(object: wrappered)
        }else{
            if (isCellSelectionEnabled){
                smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForNotSelectedWrapperedObject(object: wrappered)
            }else{
                smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(object: wrappered)
            }
        }
        
        separatorView.isHidden = isBigSize()
        barView.backgroundColor = isBigSize() ? ColorConstants.fileGreedCellColor : UIColor.white
        
        //Big size (Grid)
        if (isBigSize() && (bottomViewH.constant == BasicCollectionMultiFileCell.bigH)){
            bottomViewH.constant = BasicCollectionMultiFileCell.smallH
            
            smallContentImageViewW.constant = BasicCollectionMultiFileCell.smallContentImageViewWConst
            smallContentImageViewH.constant = BasicCollectionMultiFileCell.smallContentImageViewHConst
            
            leftSpaceForSmallmage.constant = BasicCollectionMultiFileCell.leftSpaceBigCell
            
            layoutIfNeeded()
        }
        
        //Small size (list)
        if (!isBigSize() && (bottomViewH.constant != BasicCollectionMultiFileCell.bigH)){
            bottomViewH.constant = BasicCollectionMultiFileCell.bigH
            
            smallContentImageViewW.constant = BasicCollectionMultiFileCell.smallContentImageViewBigSize
            smallContentImageViewH.constant = BasicCollectionMultiFileCell.smallContentImageViewBigSize
            
            leftSpaceForSmallmage.constant = BasicCollectionMultiFileCell.leftSpaceSmallCell
            
            fileNameLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            layoutIfNeeded()
        }
        
        topFavoritesStar.isHidden = !wrappered.favorites
        bottomFavoritesStar.isHidden = !wrappered.favorites
        if (isBigSize()){
            bottomFavoritesStar.isHidden = true
        }else{
            topFavoritesStar.isHidden = true
        }
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool){
        smallCellSelectionView.isHidden = true
        moreButton.isHidden = isSelectionActive
        smallContentImageView.isHidden = false
        
        if (isSelectionActive){
            topFavoritesStar.isHidden = true
            bottomFavoritesStar.isHidden = true
        }else{
            if itemModel != nil {
                if (isBigSize()){
                    topFavoritesStar.isHidden = !itemModel!.favorites
                    bottomFavoritesStar.isHidden = true
                }else{
                    topFavoritesStar.isHidden = true
                    bottomFavoritesStar.isHidden = !itemModel!.favorites
                }

            }
        }
        
        isCellSelected = isSelected
        isCellSelectionEnabled = isSelectionActive
        selectionImageView.isHidden = !isSelectionActive
        var bgColor: UIColor = ColorConstants.whiteColor
        if (isSelectionActive){
            selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
            if (isBigSize()){
                UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                    self.bigSelectionView.alpha = isSelected ? 1 : 0
                })
                smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
            }else{
                self.bigSelectionView.alpha = 0
                bgColor = ColorConstants.whiteColor
                if (!smallContentImageView.configured){
                    smallCellSelectionView.isHidden = !isSelected
                    smallContentImageView.isHidden = isSelected
                }
                smallContentImageView.setSelection(selection: isSelected, showSelectonBorder: isSelectionActive)
            }
        }else{
            if (isBigSize()){
                bgColor = ColorConstants.fileGreedCellColor
                if (self.bigSelectionView.alpha != 0){
                    UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                        self.bigSelectionView.alpha = 0
                    })
                }
            }else{
                bgColor = ColorConstants.whiteColor
            }
            smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
        }
        
        bgView.backgroundColor = bgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        smallSelectonView.layer.borderWidth = 3
        smallSelectonView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
        smallSelectonView.alpha = 0
        
        bigSelectionView.layer.borderWidth = 3
        bigSelectionView.layer.borderColor = ColorConstants.darcBlueColor.cgColor
        bigSelectionView.alpha = 0
        
        fileNameLabel.font = UIFont.TurkcellSaturaRegFont(size: 10)
        fileNameLabel.textColor = ColorConstants.textGrayColor
        
    }
    
    override func updating(){
        super.updating()
        smallContentImageView.configured = false
        smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        actionDelegate?.morebuttonGotPressed(sender: sender, itemModel: itemModel)
    }
}
