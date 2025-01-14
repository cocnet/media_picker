//
//  FBVideoPickImageCCell.m
//  multi_image_picker
//
//  Created by amzwin on 2022/3/28.
//

#import "FBVideoPickImageCCell.h"
#import "UIColor+NvColor.h"
#import <Masonry/Masonry.h>

@implementation FBVideoPickImageCCell
{
    UIImageView *imageView;
    UIView *maskView;
}

+(NSString*)identifier{
    return NSStringFromClass(self);
}

+(CGSize)itemSize{
    return CGSizeMake(52, 52);
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.clipsToBounds = YES;
    
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

-(void)fillContentView:(FBVideoImageModel*)data{
    imageView.image = data.cropImage;
    maskView.hidden = data.isSelected;
    if(data.isSelected){
        imageView.layer.borderWidth = 2;
        imageView.layer.cornerRadius = 4;
    }else{
        imageView.layer.borderWidth = 0;
        imageView.layer.cornerRadius = 0;
    }
}

#pragma mark - UI
-(void)setupUI{
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.masksToBounds = YES;
    [self addSubview:imageView];
    
    maskView = [[UIView alloc] init];
    maskView.backgroundColor = [UIColor nv_colorWithHexString:@"0x000000" alpha:0.3];
    [self addSubview:maskView];
}

-(void)setupUILayout{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
@end
