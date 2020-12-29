//
//  IntroduceDataSource.swift
//  Depo
//
//  Created by Oleg on 12.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol IntroduceDataSourceEventsDelegate: class {
    func pageChanged(page: Int)
}

class IntroduceDataSource: NSObject, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    weak var delegate: IntroduceDataSourceEventsDelegate?
    
    func configurateScrollViewWithModels(models: [IntroduceModel]) {
        let w = scrollView.frame.width
        let h = scrollView.frame.height
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        var x: CGFloat = 0
        
        for model in models {
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
        
        if (models.count <= 1) {
            pageControll.isHidden = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = x / scrollView.frame.size.width
        pageControll.currentPage = Int(page)
    }
    
    @objc func valueChanged() {
        delegate?.pageChanged(page: pageControll.currentPage)
        let page = pageControll.currentPage
        let x = CGFloat(page) * scrollView.frame.size.width
        let rect = CGRect(x: x, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
}
