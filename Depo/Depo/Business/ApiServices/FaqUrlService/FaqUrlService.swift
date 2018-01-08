//
//  FaqUrlService.swift
//  Depo
//
//  Created by Ryhor on 24.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

class Faq : ObjectRequestResponse {
    var faqUrl: String?
    
    override func mapping() {
        faqUrl = self.jsonString
    }
}

struct FAQUrl:RequestParametrs{
    var requestParametrs: Any {
        return ""
    }
    
    var patch: URL {
        let path = String(format: RouteRequests.faqUrl, Device.locale)
        return URL(string: path, relativeTo:RouteRequests.BaseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.base()
    }
}

class FaqUrlService: BaseRequestService{

  func requestFaqUrl(success: SuccessResponse?, fail: FailResponse?){
        log.debug("FaqUrlService requestFaqUrl")
    
        let faq = FAQUrl()
        let handler = BaseResponseHandler<Faq,ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param:faq, handler: handler)
    }
    
  static func faqBuilder()->([FAQSectionItem], [String]){
        let questions:[FAQSectionItem] = [FAQSectionItem(title: "What is lifebox?"),
                                          FAQSectionItem(title: "How Can I Reach lifebox?"),
                                          FAQSectionItem(title: "How Can I Start Using lifebox?"),
                                          FAQSectionItem(title: "How can I log In At lifebox?"),
                                          FAQSectionItem(title: "What is the lifebox Welcome Package?"),
                                          FAQSectionItem(title: "Is lifebox a paid for app?"),
                                          FAQSectionItem(title: "How is mobile internet charging carried out?"),
                                          FAQSectionItem(title: "Will the data that I save in lifebox get lost?"),
                                          FAQSectionItem(title: "Do third parties have access to the data that I have saved in lifebox?"),
                                          FAQSectionItem(title: "What will happen to my data in lifebox when I hand over my line?"),
                                          FAQSectionItem(title: "What are the terms and conditions for auto-renewing subscriptions?"),
                                          FAQSectionItem(title: "Privacy Policy")]
        let answers:[String] = [
        "lifebox is a storage service where you can save your pictures, videos, music and files, where you can reach these files by phone, tablet or PC at any point where you have access to internet and where you can easily share these files. All subscribers who download the app and log in will receive a 5 GB storage space as a gift. You can purchase a package to increase storage space. Purchased packages are automatically renewed each month.",
        "If you are a Turkcell subscriber, write lifebox and send a free of charge SMS to 2222 or download the lifebox app from the app markets T-Market, Google Play, Apple Appstore. If you are not a Turkcell subscriber, you can download the lifebox app from the app markets Google Play and Appstore. All users can reach the app on the website www.mylifebox.com.",
        "By you can download the app on your iOS and Android device (If you are a Turkcell subscriber, write lifebox and send a free of charge SMS to 2222, If you are not a Turkcell subscriber you can obtain it on Google Play, Apple Appstore) or if you do not have a smart phone, you can log in at www.mylifebox.com and start using the service.",
        "After opening the lifebox app, you can log in automatically by way of 3G mobile internet if you are a Turkcell subscriber. While connected on Wi-Fi, if you have determined your Turkcell Password or a different password while registering when you enter your Turkcell phone number or the e-mail address that you entered while registering, you can log in to the app by writing this password. Furthermore, you can also access lifebox with your Turkcell Password or the password that you determined on the website www.mylifebox.com. If you are not a Turkcell subscriber, you can log in the app by writing the telephone number or e-mail address that you entered when registering or the password that you determined. Furthermore, you can access lifebox with the password that you determined on the website www.mylifebox.com",
        "The lifebox Welcome Package (5 GB storage space) is free of charge. The Welcome package is automatically defined free of charge for subscribers who write lifebox and send a free of charge SMS to 2222 or who log in to the app or the website www.mylifebox.com",
        "It is free of charge to download lifebox app. The data traffic that arises when downloading from T-Market on Android devices will not be charged. The data traffic that arises when downloading from Google Play and Apple Appstore will be charged on your package if you have an internet package, otherwise it will be charged on your current tariff.",
        "Traffic that arises during downloading, sharing on social networks and e-mail, following/listening and uploading proceedings will be charged on your package if you have a mobile internet package or if not, on your current tariff. Furthermore, you can update the lifebox app with the Automatic Upload option from the Settings menu as Wi-Fi/3G, Wi-Fi or as Closed. Traffic that arises during usage by way of VINN, will be charged on your current VINN tariff. During usage abroad, you will be charged on the overseas mobile internet tariff of the operator you selected in the country of your location.",
        "No, as long as your subscription continues and you do not annul the service, your data will remain saved in safety in lifebox.",
        "No, you can only log in to lifebox with the password that you have determined or with Turkcell Password, which is special to you, if you are a Turkcell subscriber. Third parties do not have access.",
        "If your e-mail address is registered in lifebox, your first login to the lifebox app after handing over your line must be using Wifi connection. You should enter your registered e-mail and the password you have determined. Then, you can access all your data present in lifebox. Otherwise, all your data present in lifebox (photos, videos, music, files, directories) will be erased.",
        "Subsriptions are renewed on a monthly basis.\nFees are charged upon your iTunes account.\nSubsriptions are renewed on a monthly basis unless auto-renewal option is off . Subscriptions are not renewed if subcription is cancelled within 24 hours before the renewal date.\nThe account may be charged within 24 hours before the subscription renewal date is due. The fees are reflected as they are shown on the in-app purchase screen.\nSusbcriptions are managed by the user and/or can be closed via using the settings section under My Account.\nThe subsriptions can not be terminated within a month following the last fee withdrawal for the service.\nFree 5 GB package will be terminated as the periodic montly subscription fee begins. \n\nMonthly subscription fees:\nApple Store 50GB Package:\nTurkey: 4,99 TL\n\nApple Store 500GB Package\nTurkey: 12,99 TL\n\nApple Store 2.5TB Package:\nTurkey: 29,99 TL",
        "Here's the link for privacy policy https://m.turkcell.com.tr/tr/gizlilik-ve-guvenlik"]
        
        
        return (questions,answers)
        
    }
}
