//
//  Constant.swift
//  Ⓟusher
//
//  Created by Mohammad Arafat Hossain on 4/10/20.
//  Copyright © 2020 Mohammad Arafat Hossain. All rights reserved.
//

import Foundation

enum Constant {
    case appName
    case xcodeFailed
    case selectItem
    case close
    case activate
    case selectbundle
    case editPush
    case sendPush
    case editPayload
    case update
    case payload
    
    var message: String {
        switch self {
        case .appName: return "Ⓟusher"
        case .xcodeFailed: return "Please change xcode command version to minimum 13.5"
        case .selectItem: return "⇠ Please select from left"
        case .close: return "Close"
        case .activate: return "Activate"
        case .selectbundle: return "Select App ☞"
        case .sendPush: return "Send push notification"
        case .editPush: return "Edit Push notification"
        case .editPayload: return "Edit Payload"
        case .update: return "Update"
        case .payload: return """
        {
            "aps": {
                "alert": {
                    "body": "Hello!",
                    "title": "From Ⓟusher"
                }
            }
        }
        """
        }
    }
}
