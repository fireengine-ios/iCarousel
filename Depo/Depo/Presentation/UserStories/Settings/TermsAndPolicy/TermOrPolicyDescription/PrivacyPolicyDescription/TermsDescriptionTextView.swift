//
//  TermsDescriptionTextView.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//


import UIKit

final class TermsDescriptionTextView: UIViewController {
    
    var textToPresent: NSAttributedString = NSMutableAttributedString(string: "")
    
    init(text: NSAttributedString) {
        textToPresent = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.TurkcellSaturaRegFont(size: 15)
        textView.textColor = .black
        
        let edgeInset: CGFloat = 16
        textView.contentInset = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        return textView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
        textView.attributedText = textToPresent
        setTitle(withString: TextConstants.termsOfUseCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    private func setupLayout() {
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        textView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
    }
}
