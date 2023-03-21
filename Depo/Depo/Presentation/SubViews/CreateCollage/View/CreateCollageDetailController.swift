//
//  CreateCollageDetailController.swift
//  Depo
//
//  Created by Ozan Salman on 13.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class CreateCollageDetailController: BaseViewController {
    
    private var collageTemplate: CollageTemplate?
    var collectionView: UICollectionView?
    weak var delegate: CreateCollageTableViewCellDelegate?
    var output: CreateCollageViewOutput!
    
    init(collageTemplate: CollageTemplate) {
        self.collageTemplate = collageTemplate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("CreateCollage viewDidLoad")
        
        
        
        
        setTitle(withString: "See All")
        view.backgroundColor = .white
        collectionViewConfigure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func collectionViewConfigure() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cellWidth = (view.frame.size.width - 40) / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        let collectionViewFrame = CGRect(x: self.view.frame.origin.x + 10 , y: self.view.frame.origin.y + 10, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 20)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView?.register(CreateCollageCollectionViewCell.self, forCellWithReuseIdentifier: "CreateCollageCollectionViewCell")
        collectionView?.backgroundColor = .white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        view.addSubview(collectionView ?? UICollectionView())
    }
    
}

extension CreateCollageDetailController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collageTemplate?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateCollageCollectionViewCell", for: indexPath) as? CreateCollageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(collageTemplateModel: (collageTemplate?[safe: indexPath.row])!)
        return cell
    }
}

extension CreateCollageDetailController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let router = CreateCollageRouter()
        router.navigateToCreateCollage(collageTemplate: (collageTemplate?[safe: indexPath.row])!)
    }
}
