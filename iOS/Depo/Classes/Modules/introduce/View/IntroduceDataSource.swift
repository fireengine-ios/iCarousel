//
//  IntroduceDataSource.swift
//  Depo
//
//  Created by Oleg on 12.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class IntroduceDataSource: NSObject, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var pageControll:UIPageControl!
    
    func configurateScrollViewWithModels(models:[IntroduceModel]){
        let w = self.scrollView.frame.size.width
        let h = self.scrollView.frame.size.height
        for view in self.scrollView.subviews{
            view.removeFromSuperview()
        }
        var x: CGFloat = 0
        
        for model in models{
            let subView = IntroduceSubView.initFromNib()
            subView.frame = CGRect(x: x, y: 0, width: w, height: h)
            x = x + w
            subView.setModel(model: model)
            self.scrollView.addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSize(width: x, height: h)
        self.pageControll.numberOfPages = models.count
        self.pageControll.currentPage = 0
        
        self.pageControll.addTarget(self, action: #selector(valueChanged), for: UIControlEvents.valueChanged)
        
        if (models.count <= 1){
            self.pageControll.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = x / self.scrollView.frame.size.width
        self.pageControll.currentPage = Int(page)
    }
    
    func valueChanged(){
        let page = self.pageControll.currentPage
        let x = CGFloat(page) * self.scrollView.frame.size.width
        let rect = CGRect(x: x, y: 0, width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
        self.scrollView.scrollRectToVisible(rect, animated: true)
    }
    
}
