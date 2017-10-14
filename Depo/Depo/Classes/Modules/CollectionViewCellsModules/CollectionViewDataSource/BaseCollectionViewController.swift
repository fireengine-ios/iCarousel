//
//  BaseCollectionViewController.swift
//  Depo
//
//  Created by Oleg on 26.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseCollectionViewController: UIViewController {

    var calculatedH:CGFloat = 0
    var calculatedW:CGFloat = 0
    let custoPopUp = CustomPopUp()
    
    class func getSizeFoCurrentCell()->CGSize{
        return CGSize(width: 90.0, height: 90.0)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configurateView()
    }
    
    func configurateView(){
        
    }

    func calculateHeight(forWidth width:CGFloat){
        if (calculatedH == 0){
            calculatedH = view.frame.size.height
        }
    }
    
    func calculateWidth(){
        if (calculatedW == 0){
            calculatedW = view.frame.size.width
        }
    }
    
    

}
