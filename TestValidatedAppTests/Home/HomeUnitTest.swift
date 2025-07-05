//
//  DownloadTest.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 7/7/25.
//

import Testing
import XCTest

@testable import TestValidatedApp

final class HomeUnitTest {
    let downloadLinkTest = "https://videos.pexels.com/video-files/4114797/4114797-uhd_3840_2160_25fps.mp4"
    
    @Test("Test download func")
    func downloadTest() throws {
        let homeViewModel = HomeViewModel(navigator: HomeNavigator())
        var isFinish = false
        
        homeViewModel
            .downloadVideo(
                from: downloadLinkTest,
                progressCompletion: { progress in
                    #expect(progress == 1)
                }, didFinishTask: {
                    isFinish = true
                })
        // Expect fail because the finish task is async
        #expect(isFinish == true)
    }
}
