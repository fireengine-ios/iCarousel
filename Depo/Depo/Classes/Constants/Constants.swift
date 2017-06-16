//
//  Constants.swift
//  Depo
//
//  Created by Oleg on 13.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

struct ColorConstants {
    static let whiteColor = UIColor.white
    static let blueColor = UIColor(red: 68/255, green: 204/255, blue: 208/255, alpha: 1)
    static let yellowColor = UIColor(red: 1, green: 240/255, blue: 149/255, alpha: 1)
    static let disableColor = UIColor.gray
}

struct TextConstants {
    static let itroViewGoToRegisterButtonText = "Start using Lifebox now!"
    static let introViewGoToLoginButtonText = "I have an account, let me log in"
    
    static let registrationCellTitleEmail = NSLocalizedString("EmailTitle", comment: "")
    static let registrationCellTitleGSMNumber = "GSM Number"
    static let registrationCellTitlePassword = NSLocalizedString("PasswordPlaceholder", comment: "")
    static let registrationCellTitleReEnterPassword = "Re-Enter Password"
    static let registrationCellInitialTextEmail = "   You have to fill in your mail"
    static let registrationCellInitialTextFillPassword = "   You have to fill in a password"
    static let registrationCellInitialTextReFillPassword = "  You have to fill in a password"
    
    static let termsAndUsesTitile = "Register"
    static let termsAndUsesApplyButtonText = "Accept  Terms"
    static let termsAndUseTextFormat = "<html><body text=\"#FFFFFF\" face=\"Bookman Old Style, Book Antiqua, Garamond\" size=\"5\">%@</body></html>"
    
    static let loginTitle = NSLocalizedString("Login", comment: "")
    static let loginCantLoginButtonTitle = "I can't login"
    static let loginRememberMyCredential = "Remember my credentials"
    static let loginCellTitleEmail = "E-Mail or GSM Number"
    static let loginCellTitlePassword = NSLocalizedString("PasswordPlaceholder", comment: "")
    static let loginCellEmailPlaceholder = "E-Mail or GSM Number"
    static let loginCellPasswordPlaceholder = ""
    
    static let registerTitle = "Register"
    
    static let forgotPasswordTitle = "Forgot My Password"
    static let forgotPasswordSubTitle = "If you registered with your Turkcell Number you can just send SIFRE LIFEBOX to 2222 to recieve a new password or enter your mail below."
    static let forgotPasswordSendPassword = "Send password reset link"
    static let forgotPasswordCellTitle = NSLocalizedString("EmailTitle", comment: "")
    
    static let serverResponceError = "Wrong type of answer"
    
    // MARK: Authification Cells
    static let showPassword = "Show"
    static let hidePassword = "Hide"
    
    
    // MARK:
}


struct FontNamesConstant {
    static let turkcellSaturaBol = "TurkcellSaturaBol"
}

