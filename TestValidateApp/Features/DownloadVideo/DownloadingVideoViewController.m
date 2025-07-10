//
//  DownloadingVideoViewController.m
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 10/7/25.
//

#import "DownloadingVideoViewController.h"
#import "HLSUrl.h"
#import "TestValidateApp-Swift.h"

@interface DownloadingVideoViewController ()
@property (nonatomic, strong) DownloadVideoViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIView *tableViewWrapView;
@property (weak, nonatomic) IBOutlet UITableView *downloadListTableView;

@property (nonatomic, strong) NSArray<DownloadTableCellModel *> *listDownloadItem;
@end

@implementation DownloadingVideoViewController

- (instancetype)initWithViewModel:(DownloadVideoViewModel *)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setUpTableView];
}

- (void)setUpTableView {
    self.downloadListTableView.estimatedRowHeight = 100.0;
    self.downloadListTableView.rowHeight = UITableViewAutomaticDimension;

    self.downloadListTableView.delegate = self;
    self.downloadListTableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"DownloadTableViewCell" bundle:nil];
    [self.downloadListTableView registerNib:nib forCellReuseIdentifier:@"DownloadTableViewCell"];
    self.listDownloadItem = @[
        [[DownloadTableCellModel alloc] initWithTitle:@"Video 1"
                                                                              subtitle:@"Downloading..."
                                                                                status:DownloadStatusDownloading
                                                                               progress:0.2
                                                                          errorMessage:nil],
        [[DownloadTableCellModel alloc] initWithTitle:@"Video 2"
                                                                              subtitle:@"Almost done"
                                                                                status:DownloadStatusDownloading
                                                                               progress:0.9
                                                                          errorMessage:nil],
    ];
}

- (void)setUpUI {
    self.urlTextField.placeholder = @"Enter URL";
    self.urlTextField.text = kHLSUrl;

    self.downloadButton.backgroundColor = [[UIColor alloc] initWithRgb:0x008789];
    [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    self.downloadButton.tintColor = [UIColor whiteColor];
    self.downloadButton.layer.cornerRadius = 8;
    self.downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    
    [self.tableViewWrapView roundCornersWithCorners:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner radius:24];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listDownloadItem.count; // hoặc count của mảng dữ liệu
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Title %ld", (long)indexPath.row];
    cell.subtitleLabel.text = @"Subtitle here";
    [cell.indicator startAnimating];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select row %ld", (long)indexPath.row);
}

@end

////- (IBAction)didTouchButton:(UIButton *)sender {
////    if (sender == self.startButton) {
////        // TODO: Implement HLS download.
////        NSLog(@"start");
////    } else if (sender == self.playButton) {
////        // TODO: Play downloaded video file.
////        NSLog(@"play");
////    }
////}
//
//@end
