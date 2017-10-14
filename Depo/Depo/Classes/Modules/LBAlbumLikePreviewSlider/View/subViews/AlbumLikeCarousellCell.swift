//
//  AlbumLikeCarousellCell.swift
//  Depo
//
//  Created by Aleksandr on 8/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class AlbumLikeCarousellCell: UIView {
 
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var previewImage: LoadingImageView!
    
    
    class func initFromXIB() -> AlbumLikeCarousellCell {
        let view = UINib(nibName: "AlbumLikeCarousellCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! AlbumLikeCarousellCell
        view.setupInitialConfig()
        return view
    }
    
    private func setupInitialConfig() {
        
    }
   
    func setup(forItem item: Item, titleText: String) {
        previewImage.loadImageForItem(object: item)
//        previewImage.image = image
        titleLabel.text = titleText
    }
    
}
