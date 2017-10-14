//
//  Mail.swift
//  Depo
//
//  Created by Oleg on 05.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import MessageUI

class Mail: NSObject, MFMailComposeViewControllerDelegate {
    
    private static var uniqueInstance: Mail?
    
    private var mailController: MFMailComposeViewController? = nil
    
    private override init() {}
    
    class func canSendEmail() -> Bool{
        return MFMailComposeViewController.canSendMail()
    }
    
    static func shared() -> Mail {
        if uniqueInstance == nil {
            uniqueInstance = Mail()
        }
        return uniqueInstance!
    }
    
    func sendEmail(emailBody: String, subject: String, emails: [String]){
        if (!Mail.canSendEmail()){
            return
        }
        mailController = MFMailComposeViewController()
        mailController!.mailComposeDelegate = self
        mailController!.setToRecipients(emails)
        mailController!.setSubject(subject)
        mailController!.setMessageBody(emailBody, isHTML: false)
        let controller = RouterVC().rootViewController
        guard let contr_ = controller else{
            return
        }
        contr_.present(mailController!, animated: true) { 
            
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        mailController!.dismiss(animated: true) { 
            
        }
    }
    
}
