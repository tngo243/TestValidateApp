//
//  UseCaseProvider.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation

class UseCaseProvider {
    static func makeVideUseCase() -> VideoUseCase {
        return VideoUseCase()
    }
}
