//
//  String+Exts.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation

extension String {
    var validURL: Bool {
        get {
            let urlRegEx = #"^(https?://)?((www\.|[a-zA-Z0-9])[a-zA-Z0-9-]*[a-zA-Z0-9]\.)+[^\s]{2,}$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
            return predicate.evaluate(with: self)
        }
    }
}

