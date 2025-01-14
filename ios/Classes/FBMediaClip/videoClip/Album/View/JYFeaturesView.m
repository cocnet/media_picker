//
//  JYFeaturesView.m
//  SDKDemo
//
//  Created by yzhon 2019/3/21.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "JYFeaturesView.h"
#import "TZImagePickerController.h"
#import "Masonry.h"

@implementation JYFeaturesView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSArray *titles = @[NSLocalizedString(@"剪辑", nil), NSLocalizedString(@"滤镜", nil), NSLocalizedString(@"字幕", nil), NSLocalizedString(@"音乐", nil)];
        
        NSArray *selectImages = @[[NSString stringWithFormat:@"%@1", NSLocalizedString(@"剪辑", nil)],
                                  [NSString stringWithFormat:@"%@1", NSLocalizedString(@"滤镜", nil)],
                                  [NSString stringWithFormat:@"%@1", NSLocalizedString(@"字幕", nil)],
                                  [NSString stringWithFormat:@"%@1", NSLocalizedString(@"音乐", nil)]];
        NSInteger number = titles.count;
        for (int i=0; i<number; i++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.hidden = YES;
            [btn setImage:[UIImage tz_imageNamedFromMyBundle:titles[i]] forState:UIControlStateSelected];
            [btn setImage:[UIImage tz_imageNamedFromMyBundle:selectImages[i]] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 300 + i;
            btn.frame = CGRectMake(0, 0, 30.0, 30.0);
            btn.center = CGPointMake(frame.size.width / 2 / number * (2 * i + 1), 15.0);
            [self addSubview:btn];
            
            UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            titleBtn.hidden = YES;
            [titleBtn setTitle:titles[i] forState:UIControlStateNormal];
            [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [titleBtn setTitleColor:[UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
            [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            titleBtn.tag = 400 + i;
            [self addSubview:titleBtn];
            
            [titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(btn.mas_bottom);
                make.centerX.mas_equalTo(btn);
            }];
            
            if (i == 0) {
                
                btn.selected = YES;
                titleBtn.selected = YES;
            }
        }
    }
    return self;
}

- (void)btnClick:(UIButton *)btn {
    
    //NSLog(@"点击：%d", btn.tag - 300);
    
    [self click:btn.tag - 300];
}

- (void)click:(NSInteger)index {
    
    for (int i=0; i<4; i++) {
        
        UIButton *btn1 = (UIButton *)[self viewWithTag:300 + i];
        UIButton *btn2 = (UIButton *)[self viewWithTag:400 + i];
        if (index == i) {
            
            btn1.selected = YES;
            btn2.selected = YES;
        } else {
            
            btn1.selected = NO;
            btn2.selected = NO;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(featuresViewBtnClick:)]) {
        
        [self.delegate featuresViewBtnClick:index];
    }
}

- (void)titleBtnClick:(UIButton *)btn {
    
    //NSLog(@"点击：%d", btn.tag - 400);
    [self click:btn.tag - 400];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
