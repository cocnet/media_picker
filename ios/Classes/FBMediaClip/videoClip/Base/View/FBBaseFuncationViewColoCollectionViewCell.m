//
//  FBBaseFuncationViewColoCollectionViewCell.m
//  multi_image_picker
//
//  Created by 杨志豪 on 3/21/22.
//

#import "FBBaseFuncationViewColoCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface FBBaseFuncationViewColoCollectionViewCell()

@end

@implementation FBBaseFuncationViewColoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.mainImageView = [[UIImageView alloc] init];
        self.mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.mainImageView];
        
        self.mainTitleLabel = [[UILabel alloc] init];
        self.mainTitleLabel.font = [UIFont systemFontOfSize:10];
        self.mainTitleLabel.textColor = [UIColor whiteColor];
        self.mainTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.mainTitleLabel];
        
        [self.mainImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY).offset(-8);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];
        
        [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.mainImageView.mas_bottom).offset(4);
        }];
    }
    return self;
}
@end
