//
//  String+Exts.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 2/7/25.
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
