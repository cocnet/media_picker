//
//  JYAlbumListView.m
//  VideoClip
//
//  Created by yzh on 2019/7/1.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYAlbumListView.h"
#import "JYAlbumListTableViewCell.h"
#import "FBVideoCLipHeader.h"
#import "TZImageManager.h"
#import "NSBundle+TZImagePicker.h"

@interface JYAlbumListView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong)NSMutableArray<PHAssetCollection *> *modelArr;

@property (nonatomic, strong)UILabel *emptyLabel;

@end

@implementation JYAlbumListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.backgroundColor = [UIColor colorWithHex: 0x1A2033];
        self.tableview = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height) style: UITableViewStylePlain];
        self.tableview.backgroundColor = [UIColor colorWithHex:0x1A2033];
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.tableview.rowHeight = 120;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableview.separatorColor = [UIColor clearColor];
        [self.tableview registerNib:[UINib nibWithNibName: @"JYAlbumListTableViewCell" bundle:[NSBundle tz_imagePickerBundle]] forCellReuseIdentifier: @"JYAlbumListTableViewCell"];
        [self addSubview:self.tableview];
        //监听是否重新进入程序程序.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadAlbumListTableview)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        self.emptyLabel.text = @"正在读取相册中...";
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.emptyLabel];
        self.emptyLabel.center = self.center;
        self.emptyLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)loadAlbumListTableview{
    if (self.modelArr.count > 0) {
        [self.tableview reloadData];
    }
}

-(void)fillViewContent:(NSArray<PHAssetCollection *> *)list{
    self.modelArr = list;
    [self.tableview reloadData];
}

- (void)loadAlbumList {
    
}

#pragma mark -- UITabelViewData
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(!self.modelArr) return 0;
    
    self.emptyLabel.hidden = self.modelArr.count != 0;
    return self.modelArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JYAlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYAlbumListTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row < self.modelArr.count) {//此处有崩溃，应该是 113 ~ 117 代码所致
        [cell setupModel:self.modelArr[indexPath.row]];
    }
    return cell;
}

#pragma mark -- UITabelViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PHAssetCollection *model = self.modelArr[indexPath.row];
    if (self.didSelectBlock) {
        self.didSelectBlock(model);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[JYCollectionViewImageTool shareInstance] removeAllData];
}
@end
