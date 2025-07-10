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

//@property (nonatomic, strong) NSArray<DownloadTableCellModel *> *listDownloadItem;
@end

@implementation DownloadingVideoViewController

- (instancetype)initWithViewModel:(DownloadVideoViewModel *)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _viewModel = viewModel;
        _viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setUpTableView];
    [self.viewModel viewDidLoad];
}

- (void)setUpTableView {
    [self.downloadListTableView setContentInset:UIEdgeInsetsMake(8, 0, 100, 0)];
    self.downloadListTableView.showsVerticalScrollIndicator = NO;
    self.downloadListTableView.showsHorizontalScrollIndicator = NO;
    self.downloadListTableView.estimatedRowHeight = 100.0;
    self.downloadListTableView.rowHeight = UITableViewAutomaticDimension;

    self.downloadListTableView.delegate = self;
    self.downloadListTableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"DownloadTableViewCell" bundle:nil];
    [self.downloadListTableView registerNib:nib forCellReuseIdentifier:@"DownloadTableViewCell"];
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
- (IBAction)downloadTapped:(UIButton *)sender {
    NSString *urlString = self.urlTextField.text;
    NSLog(@"Download URL: %@", urlString);
    [_viewModel downloadVideoWithUrl:urlString];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.getListVideoDownloadingItem.count; // hoặc count của mảng dữ liệu
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell" forIndexPath:indexPath];

    DownloadTableCellModel *cellModel = [self.viewModel getListVideoDownloadingItem][indexPath.row];
    [cell setUpCellWithCellModel:cellModel];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select row %ld", (long)indexPath.row);
}

#pragma mark - ViewModel
//@objc func userListViewModelDidStartLoading(_ viewModel: DownloadVideoViewModel)
//@objc func downloadVideoViewModel(_ viewModel: DownloadVideoViewModel, didFinishWithSuccess success: Bool)
- (void)downloadVideoViewModelUpdateListItem:(DownloadVideoViewModel *)viewModel {
    [self.downloadListTableView reloadData];
}
- (void)downloadVideoViewModel:(DownloadVideoViewModel *)viewModel didFinishWithSuccess:(BOOL)success {
    NSLog(@"View model finished loading with success: %@", success ? @"YES" : @"NO");
}

@end
