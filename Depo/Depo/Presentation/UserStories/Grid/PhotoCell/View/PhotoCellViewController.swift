//
//  PhotoCellPhotoCellViewController.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoCellViewController: BaseCollectionViewController, PhotoCellViewInput {

    var output: PhotoCellViewOutput!
    var interactor: PhotoCellInteractor!
    
    @IBOutlet weak var imagePreviewimageView: UIImageView!
    @IBOutlet weak var cloudStatusImage: UIImageView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spiner.startAnimating()
        
        output.viewIsReady()
    }


    // MARK: PhotoCellViewInput
    func setupInitialState() {
        
    }
    
    func showImage(image: UIImage){
        spiner.stopAnimating()
        cloudStatusImage.image = UIImage(named: "ObjectNotInCloud")
        imagePreviewimageView.image = image
    }
    
}
