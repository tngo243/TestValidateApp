//
//  Extension+FileManager.swift
//  TestValidateApp
//
//  Created by Thien Tung on 2/7/25.
//

import Foundation

extension FileManager {
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
