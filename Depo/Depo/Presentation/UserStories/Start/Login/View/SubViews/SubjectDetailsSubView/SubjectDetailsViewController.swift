//
//  SubjectDetailsViewController.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SubjectDetailsViewController: BasePopUpController, NibInit {
    @IBOutlet private weak var detailsView: UIView!
    @IBOutlet private weak var textView: UITextView!
    
    @IBOutlet private weak var subjectLabel: UILabel! {
        willSet {
            newValue.text = type?.localizedTitle
            newValue.adjustsFontSizeToFitWidth = true
            newValue.minimumScaleFactor = 0.5
        }
    }
    
    var type: SupportFormSubjectType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapRecognizer()
        convertHtmlToAttributedString()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.setContentOffset(.zero, animated: false)
    }
    
    @IBAction private func onCancelButtonTapped(_ sender: UIButton) {
        dismissSubjectDetailsViewController()
    }
    
    private func dismissSubjectDetailsViewController() {
        close()
    }
    
    private func addTapRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        view.addGestureRecognizer(recognizer)
    }
    
    private func convertHtmlToAttributedString() {
        let font = UIFont.TurkcellSaturaFont(size: 15)
        
        let htmlText = "<span style=\"color:rgba(32,33,34,0.8); font-family: '\(font.familyName)'; font-size: \(font.pointSize)\">\(type?.localizedInfoHtml ?? "")</span>"
        
        guard let htmlTextData = htmlText.data(using: .unicode, allowLossyConversion: false) else {
            assertionFailure()
            return
        }
        
        
        
        do {
            textView.attributedText = try NSAttributedString(data: htmlTextData,
                                                             options: [.documentType: NSAttributedString.DocumentType.html],
                                                             documentAttributes: nil)
        } catch {
            debugLog("Initialisation of NSMutableAttributedString failed and run into crash")
            /// https://forums.developer.apple.com/thread/115405
            
            assertionFailure()
        }
    }
    
    @objc private func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !detailsView.frame.contains(location) {
            dismissSubjectDetailsViewController()
        }
    }
    
    static func present(with type: SupportFormSubjectType) -> SubjectDetailsViewController {
        let controller = SubjectDetailsViewController.initFromNib()
        controller.type = type
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }
}
