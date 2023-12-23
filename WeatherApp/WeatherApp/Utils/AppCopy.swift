//
//  AppCopy.swift
//  WeatherApp
//
//  Created by Dileepa Pathirana on 21/12/23.
//

import Foundation



struct AppCopy {
    
    static func getString(_ key: CopyStrings) -> String {
        return NSLocalizedString(key.rawValue, comment: "Localizable")
    }
}

enum CopyStrings: String {
    case short_keyword_error_title
    case short_keyword_error_description
    case alert_button_ok
    case api_error_title
    case api_error_message
}
