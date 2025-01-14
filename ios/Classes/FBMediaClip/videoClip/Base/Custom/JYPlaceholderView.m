//
//  JYPlaceholderView.m
//  VideoClip
//
//  Created by yzh on 2019/4/25.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYPlaceholderView.h"
#import "FBVideoCLipHeader.h"


@interface JYPlaceholderView()

@property (nonatomic, strong) UIImageView * mImageView;
@property (nonatomic, strong) UILabel * mLabel;
@property (nonatomic, strong) UIButton * mButton;

@property (nonatomic, assign) JYPlaceholderType type;

@end

@implementation JYPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame type:(JYPlaceholderType)type {
    if (self = [self initWithFrame:frame]) {
        self.type = type;
        [self setupViews];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < self.ignoreHeaderHeight || point.y > CGRectGetHeight(self.bounds) - self.ignoreFooterHeight) {
        return NO;
    }
    return [super pointInside:point withEvent:event];
}

- (void)setupViews {
    [self addSubview:self.mImageView];
    [self.mImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@174);
        make.height.equalTo(@149);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_centerY).offset(-24);
    }];
    
    [self addSubview:self.mLabel];
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY);
        make.centerX.equalTo(self);
    }];

    [self addSubview:self.mButton];
    [self.mButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@167);
        make.height.equalTo(@42);
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_centerY).offset(24);
    }];

    switch (self.type) {
        case JYPlaceholderTypeRingList:
            break;
        case JYPlaceholderTypeRingMyList:
            [self.mButton setTitle:NSLocalizedString(@"去剪辑", nil) forState:UIControlStateNormal];
            self.mLabel.text = NSLocalizedString(@"你还没有剪辑的音频哦~", nil);
            break;
        case JYPlaceholderTypeVideoMyList:
            [self.mButton setTitle:NSLocalizedString(@"去剪辑", nil) forState:UIControlStateNormal];
            self.mLabel.text = NSLocalizedString(@"你还没有剪辑的视频哦~", nil);
//            self.mImageView.image = [UIImage imageNamed:@"作品为空图"];
            break;
        case JYPlaceholderTypeAssetList:
            [self.mButton setTitle:NSLocalizedString(@"获取素材", nil) forState:UIControlStateNormal];
            self.mLabel.text = NSLocalizedString(@"暂时没有可下载素材~", nil);
//            self.mImageView.image = [UIImage imageNamed:@"作品为空图"];
            break;
        case JYPlaceholderTypeDraftsList:
//            [self.mButton setTitle:@"获取素材" forState:UIControlStateNormal];
            self.mButton.hidden = YES;
            self.mLabel.text = NSLocalizedString(@"暂时没有草稿哦~", nil);
            break;
        case  JYPlaceholderTypeNoNetworkConnect:
            self.mButton.hidden = YES;
            self.mLabel.text = NSLocalizedString(@"您的网络连接不通畅~", nil);
            break;
    }
}

- (void)doneEvent {
    if (self.doneBlock != nil) {
        self.doneBlock();
    }
}

- (UIImageView *)mImageView {
    if (!_mImageView) {
        _mImageView = [UIImageView new];
        _mImageView.image = [UIImage tz_imageNamedFromMyBundle:@"ring_empty"];
    }
    return _mImageView;
}

- (UILabel *)mLabel {
    if (!_mLabel) {
        _mLabel = [UILabel new];
        _mLabel.textColor = [UIColor colorWithHex:0x000000];
        _mLabel.font = [UIFont systemFontOfSize:12];
        _mLabel.text = NSLocalizedString(@"你还没有导入的音频哦~", nil);
        _mLabel.numberOfLines = 0;
    }
    return _mLabel;
}

- (UIButton *)mButton {
    if (!_mButton) {
        _mButton = [UIButton new];
        [_mButton setTitle:NSLocalizedString(@"视频导入音频", nil) forState:UIControlStateNormal];
        _mButton.titleLabel.textColor = [UIColor whiteColor];
        _mButton.backgroundColor = UIColorFromRGB(JYColorHexThemeRed);
        _mButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _mButton.layer.masksToBounds = YES;
        _mButton.layer.cornerRadius = 3;
        [_mButton addTarget:self action:@selector(doneEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mButton;
}

@end
