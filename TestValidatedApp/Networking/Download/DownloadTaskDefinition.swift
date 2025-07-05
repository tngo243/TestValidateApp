//
//  DownloadTaskDefinition.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 1/7/25.
//

import Foundation

protocol DownloadTaskDefinition {
    var url: String { get }
    var fileName: String { get }
    var sourceURL: URL { get }
    var destinationURL: URL { get }
}
