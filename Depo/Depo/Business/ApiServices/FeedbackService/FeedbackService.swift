//
//  FeedbackService.swift
//  Depo
//
//  Created by Oleg on 05.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//


//class FeedbackService: NSObject {

struct FeedbackPatch {
    
    static let languageList =  "account/language/list"
    static let sendSelectedLanguage = "account/language"
    
}

class FeedbackLanguage: BaseRequestParametrs {
    
    override var patch: URL {
        let path: String = String(format: FeedbackPatch.languageList)
        return URL(string: path, relativeTo: super.patch)!
    }
    
}

class SelectedLanguage: BaseRequestParametrs {
    
    var selectedLanguage: LanguageModel
    
    init (selectedLanguage: LanguageModel) {
        self.selectedLanguage = selectedLanguage
    }
    
    override var patch: URL {
        let path: String = String(format: FeedbackPatch.sendSelectedLanguage)
        return URL(string: path, relativeTo: super.patch)!
    }
    
    override var requestParametrs: Any {
        let string = selectedLanguage.languageCode ?? ""
        let data = string.data(using: .utf8)
        return data ?? NSData()
    }
    
}

class FeedbackLanguagesListResponse: ObjectRequestResponse {
    
    var languagesList = [LanguageModel]()
    
    override func mapping() {
        let dict = json?.dictionary
        guard let objects = dict?.values else {
            return
        }
        for obj in objects {
            if let model = LanguageModel(json: obj) {
                languagesList.append(model)
            }
        }
    }
    
}

typealias FeedbackLanguagesListOperation = () -> Void

class FeedbackService: BaseRequestService {
    
    func getFeedbackLanguage(feedbackLanguageParameter: FeedbackLanguage, success: SuccessResponse?, fail: FailResponse?) {
        debugLog("FeedbackService getFeedbackLanguage")
        let handler = BaseResponseHandler<FeedbackLanguagesListResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: feedbackLanguageParameter, handler: handler)
    }
    
    func sendSelectedLanguage(selectedLanguageParameter: SelectedLanguage, succes: SuccessResponse?, fail: FailResponse?) {
        debugLog("FeedbackService sendSelectedLanguage")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: succes, fail: fail)
        executePostRequest(param: selectedLanguageParameter, handler: handler)
    }
    
}
