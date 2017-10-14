//
//  SMS.swift
//  Depo
//
//  Created by Oleg on 06.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import MessageUI

class SMS: NSObject, MFMessageComposeViewControllerDelegate {

    private static var uniqueInstance: SMS?
    
    private var smsController: MFMessageComposeViewController? = nil
    
    private override init() {}
    
    class func canSendSMS() -> Bool{
        return MFMessageComposeViewController.canSendText()
    }
    
    static func shared() -> SMS {
        if uniqueInstance == nil {
            uniqueInstance = SMS()
        }
        return uniqueInstance!
    }
    
    func sendSMS(textOfSMS: String?, phones: [String]){
        if (!SMS.canSendSMS()){
            return
        }
        smsController = MFMessageComposeViewController()
        smsController!.messageComposeDelegate = self
        smsController!.recipients = phones
        smsController!.body = textOfSMS ?? ""
        
        let controller = RouterVC().rootViewController
        guard let contr_ = controller else{
            return
        }
        contr_.present(smsController!, animated: true) {
            
        }
    }
    
    //MARK: MFMessageComposeViewControllerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        smsController!.dismiss(animated: true) {
            
        }
    }
    
}
