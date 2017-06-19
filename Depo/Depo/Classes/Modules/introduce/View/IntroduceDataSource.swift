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
        let w = scrollView.frame.size.width
        let h = scrollView.frame.size.height
        for view in scrollView.subviews{
            view.removeFromSuperview()
        }
        var x: CGFloat = 0
        
        for model in models{
            let subView = IntroduceSubView.initFromNib()
            subView.frame = CGRect(x: x, y: 0, width: w, height: h)
            x = x + w
            subView.setModel(model: model)
            scrollView.addSubview(subView)
        }
        
        scrollView.contentSize = CGSize(width: x, height: h)
        pageControll.numberOfPages = models.count
        pageControll.currentPage = 0
        
        pageControll.addTarget(self, action: #selector(valueChanged), for: UIControlEvents.valueChanged)
        
        if (models.count <= 1){
            pageControll.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = x / scrollView.frame.size.width
        pageControll.currentPage = Int(page)
    }
    
    func valueChanged(){
        let page = pageControll.currentPage
        let x = CGFloat(page) * scrollView.frame.size.width
        let rect = CGRect(x: x, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
}
