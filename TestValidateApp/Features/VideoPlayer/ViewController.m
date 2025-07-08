//
//  ViewController.m
//  TestValidateApp
//
//  Created by tungngo on 26/6/25.
//

#import "ViewController.h"
#import "HLSUrl.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _urlTextField.text = kHLSUrl;
}

- (IBAction)didTouchButton:(UIButton *)sender {
    if (sender == self.startButton) {
        // TODO: Implement HLS download.
        NSLog(@"start");
    } else if (sender == self.playButton) {
        // TODO: Play downloaded video file.
        NSLog(@"play");
    }
}

@end
