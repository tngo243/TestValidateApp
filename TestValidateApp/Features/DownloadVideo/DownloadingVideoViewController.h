//
//  DownloadingVideoViewController.h
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 10/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DownloadVideoViewModel;
@protocol DownloadVideoViewModelDelegate;

@interface DownloadingVideoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DownloadVideoViewModelDelegate>

- (instancetype)initWithViewModel:(DownloadVideoViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
