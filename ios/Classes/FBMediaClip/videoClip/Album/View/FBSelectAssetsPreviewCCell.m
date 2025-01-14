//
//  FBSelectAssetsPreviewCCell.m
//  FBVideoClip
//
//  Created by amzwin on 2022/3/18.
//

#import "FBSelectAssetsPreviewCCell.h"
#import <Masonry/Masonry.h>
#import "NSBundle+TZImagePicker.h"
#import "TZImagePickerController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIColor+NvColor.h"
#import "UIView+frame.h"

@interface FBSelectAssetsPreviewCCell()
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;
@end

@implementation FBSelectAssetsPreviewCCell{
    UIImageView *imageView;
    UIButton    *deletButton;
    UILabel *timeLabel;
    
    PHAsset *curModel;
}


+(NSString*)identifier{
    return NSStringFromClass(self);
}

+(CGSize)itemSize{
    return CGSizeMake(64, 64);
}

+(CGSize)itemSizeWidthPading:(CGFloat)padding{
    return CGSizeMake(64 + padding, 64 + padding);
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 2;
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

-(void)fillCellContent:(PHAsset*)model{
    curModel = model;
    
    self.representedAssetIdentifier = model.localIdentifier;
    @weakify(self);
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model photoWidth:self.bounds.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        @strongify(self);
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([self.representedAssetIdentifier isEqualToString:model.localIdentifier]) {
            self->imageView.image = photo;
            [self setNeedsLayout];
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
//            [self hideProgressView];
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    
    
//    [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self->imageView.image = result;
//        });
//    }];

//    }

//    NSInteger minutes = ((NSInteger)(model.asset.duration / 60.0) % 60);
//    NSInteger hours = (NSInteger)(model.asset.duration / 60.0 /60.0);
//    NSInteger seconds = (NSInteger)round(model.asset.duration - 60.0 * (double)minutes - 60 * 60 * hours);
//    NSString *text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours,(long)minutes, (long)seconds];
//    NSShadow *shadow = [[NSShadow alloc]init];
//    shadow.shadowBlurRadius = 0.5;
//    shadow.shadowOffset = CGSizeMake(0, 0.7);
//    shadow.shadowColor = [UIColor blackColor];
//    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:text attributes:@{NSShadowAttributeName:shadow}];
    
//    self.timeLab.attributedText = attributedText;
//
//    if (model.asset.mediaType == PHAssetMediaTypeVideo) {
//        self.timeLab.hidden = NO;
//    } else {
//        self.timeLab.hidden = YES;
//    }
//    if (self.isRadioMode) {
//        self.rightTopImageView.image = [UIImage imageNamed:model.number > 0 ? @"common_selected" : @"椭圆1拷贝3"];
//    } else {
//        self.numberLab.hidden = model.number ? NO : YES;
//        self.maskView.hidden = model.number ? NO : YES;
//        self.numberLab.text = [NSString stringWithFormat:@"%ld", model.number];
//    }
    TZAssetModelMediaType type = [[TZImageManager manager] getAssetType:model];
    
    if (type == TZAssetModelMediaTypeVideo) {
        timeLabel.hidden = NO;
//        self.bottomView.hidden = NO;
//        self.timeLength.text = timeLength;
        timeLabel.text = [[TZImageManager manager] getNewTimeFromDurationSecond:model.duration];
//        self.videoImgView.hidden = NO;
//        _timeLength.tz_left = 5;//self.videoImgView.tz_right;
//        _timeLength.textAlignment = NSTextAlignmentRight;
    } else if (type == TZAssetModelMediaTypePhotoGif) {
        timeLabel.hidden = NO;
        timeLabel.text = @"动图";
//        self.videoImgView.hidden = YES;
//        _timeLength.tz_left = 5;
//        _timeLength.textAlignment = NSTextAlignmentRight;
    }else{
        timeLabel.hidden = YES;
        timeLabel.text = @"";
    }
}


#pragma mark - Action
-(void)deleteImg:(id)sender{
    if(self.deleteSeletedImage){
        self.deleteSeletedImage(curModel);
    }
}

#pragma mark - UI
-(void)setupUI{
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    deletButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width-16, 0, 16, 16)];
    [deletButton addTarget:self action:@selector(deleteImg:) forControlEvents:UIControlEventTouchUpInside];
    [deletButton setImage:[UIImage tz_imageNamedFromMyBundle:@"asset_delete_topright_icon"] forState:UIControlStateNormal];
    [deletButton setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 2,0)];
    deletButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    deletButton.backgroundColor = [UIColor nv_colorWithHexString:@"#1F2125" alpha:0.4];
    deletButton.layer.masksToBounds = YES;
    [deletButton setBorderWithCornerRadius:2 corners:UIRectCornerBottomLeft];
    [self addSubview:deletButton];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont boldSystemFontOfSize:11];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.backgroundColor = [UIColor colorWithRed:31/255.0 green:33/255.0 blue:38/255.0 alpha:0.55];
    timeLabel.layer.cornerRadius = 4;
    [timeLabel.layer setMasksToBounds:YES];
    [self addSubview:timeLabel];
}

-(void)setupUILayout{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
//    [deletButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(16, 16));
//        make.top.equalTo(self.mas_top).offset(0);
//        make.right.equalTo(self.mas_right).offset(0);
//    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-3);
        make.right.equalTo(self.mas_right).offset(-3);
        make.size.mas_equalTo(CGSizeMake(36, 17));
    }];
}
@end
