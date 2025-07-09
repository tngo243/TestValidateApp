//
//  DownloadVideoViewController.m
//  TestValidateApp
//
//  Created by tungngo on 26/6/25.
//

#import "DownloadVideoViewController.h"
#import "HLSUrl.h"
#import "TestValidateApp-Swift.h"

@interface DownloadVideoViewController ()

@property (nonatomic, strong) DownloadVideoViewModel *viewModel;

@end

@implementation DownloadVideoViewController

- (instancetype)initWithViewModel:(DownloadVideoViewModel *)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // set back ground green
//    let backgroundImage = UIImageView(image: UIImage(named: "backgroundImage"))
//    self.view.addSubview(backgroundImage)
//    
//    backgroundImage.translatesAutoresizingMaskIntoConstraints = false
//    NSLayoutConstraint.activate([
//        backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//        backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
//        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//    ])
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"def_back"]];
    [self.view addSubview:backgroundImage];
    backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [backgroundImage.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backgroundImage.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [backgroundImage.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backgroundImage.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

//    _urlTextField.text = kHLSUrl;
}

//- (IBAction)didTouchButton:(UIButton *)sender {
//    if (sender == self.startButton) {
//        // TODO: Implement HLS download.
//        NSLog(@"start");
//    } else if (sender == self.playButton) {
//        // TODO: Play downloaded video file.
//        NSLog(@"play");
//    }
//}

@end
