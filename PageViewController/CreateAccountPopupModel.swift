//
//  CreateAccountPopupModel.swift
//  Epic
//
//  Created by Gopal Rao Gurram on 3/22/22.
//  Copyright © 2022 Epic. All rights reserved.
//

import UIKit


enum CreateAccountPopupModel: CaseIterable {
    case pageZero
    case pageOne
    case pageTwo

    var index: Int {
        switch self {
        case .pageZero:
            return 0
        case .pageOne:
            return 1
        case .pageTwo:
            return 2
        }
    }

    static func getPages() -> [CreateAccountPopupModel] {
        return Self.isIphone() ? [.pageZero, .pageOne, .pageTwo] : [.pageZero]
    }

    func title() -> String {
        return Self.title()
    }

    static func title() -> String {
        return Self.isIphone() ? NSLocalizedString("create_account_popup_title_iPhone", tableName: "Account", bundle: .main, value: "Create an account to\nfollow their journey!", comment: "Message displayed to ask user if they like to create account for their child") : NSLocalizedString("create_account_popup_title", tableName: "Account", bundle: .main, value: "Create an account\nto follow their journey!", comment: "Message displayed to ask user if they like to create account for their child")
    }

    func backgroundImage() -> UIImage? {
        return Self.backgroundImage(for: self)
    }

    static func backgroundImage(for page: CreateAccountPopupModel) -> UIImage? {
        switch page {
        case .pageZero:
            return UIImage(named: Self.isIphone() ? "noAccount_Green_iPhone" : "noAccount_Green")
        case .pageOne:
            return UIImage(named: Self.isIphone() ? "noAccount_Pink_iPhone" : "noAccount_Pink")
        case .pageTwo:
            return UIImage(named: Self.isIphone() ? "noAccount_Purple_iPhone" : "noAccount_Purple")
        }
    }

    func subTitle() -> String {
        return Self.subTitle(for: self)
    }

    static func subTitle(for page: CreateAccountPopupModel) -> String {
        switch page {
        case .pageZero:
            return NSLocalizedString("create_account_popup_sub_title_one", tableName: "Account", bundle: .main, value: "See what they’re reading &\n for how long.", comment: "Message displayed to inform user the benefits of create account for their child")
        case .pageOne:
            return NSLocalizedString("create_account_popup_sub_title_two", tableName: "Account", bundle: .main, value: "Send kudos to reward\n their progress.", comment: "Message displayed to inform user the benefits of create account for their child")
        case .pageTwo:
            return NSLocalizedString("create_account_popup_sub_title_three", tableName: "Account", bundle: .main, value: "Recommend books you\n think they’ll love.", comment: "Message displayed to inform user the benefits of create account for their child")
        }
    }
    
    public static func isIphone() -> Bool {
        return !(UIScreen.main.traitCollection.horizontalSizeClass == .regular && UIScreen.main.traitCollection.verticalSizeClass == .regular)
    }
}
