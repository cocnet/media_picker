//
//  FBAssetsHandlerProgressView.m
//  FBVideoClip
//
//  Created by amzwin on 2022/3/19.
//

#import "FBAssetsHandlerProgressView.h"
#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "FBSelectAssetsPreviewCCell.h"
#import "UIView+frame.h"
#import "UIColor+NvColor.h"
@class FBProgressView;
@protocol FBProgressViewDelegate <NSObject>
-(void)progressViewOver:(FBProgressView *)progressView;
@end

@interface FBProgressView : UIView
//进度值0-1.0之间
@property(nonatomic,assign)CGFloat progressValue;
//内部label文字
@property(nonatomic,strong)NSString *contentText;
//value等于1的时候的代理
@property(nonatomic,weak) id<FBProgressViewDelegate> delegate;
@end


@interface FBProgressView (){
    CAShapeLayer *backGroundLayer;      //背景图层
    CAShapeLayer *frontFillLayer;       //用来填充的图层
    UIBezierPath *backGroundBezierPath; //背景贝赛尔曲线
    UIBezierPath *frontFillBezierPath;  //用来填充的贝赛尔曲线
    UILabel *_contentLabel;              //中间的label
}
@end

@implementation FBProgressView
@synthesize progressValue = _progressValue;

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //创建背景图层
        backGroundLayer = [CAShapeLayer layer];
        backGroundLayer.fillColor = nil;

        //创建填充图层
        frontFillLayer = [CAShapeLayer layer];
        frontFillLayer.fillColor = nil;

        //创建中间label
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.text = @"";
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentLabel];
        
        [self.layer addSublayer:backGroundLayer];
        [self.layer addSublayer:frontFillLayer];
        
        //设置颜色
        frontFillLayer.strokeColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        _contentLabel.textColor = [UIColor whiteColor];
        backGroundLayer.strokeColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:.5].CGColor;
    }
    return self;
    
}

#pragma mark -子控件约束
-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    _contentLabel.frame = CGRectMake(0, 0, width - 4, 20);
    _contentLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    backGroundLayer.frame = self.bounds;

    backGroundBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f) radius:(CGRectGetWidth(self.bounds)-2.0)/2.f startAngle:0 endAngle:M_PI*2
                                                       clockwise:YES];
    backGroundLayer.path = backGroundBezierPath.CGPath;
    
    frontFillLayer.frame = self.bounds;

    //设置线宽
    frontFillLayer.lineWidth = 3.0;
    backGroundLayer.lineWidth = 3.0;
}

#pragma mark - 设置label文字和进度的方法
-(void)setContentText:(NSString *)contentText {
    if (contentText) {
        _contentLabel.text = contentText;
    }
}

- (void)setProgressValue:(CGFloat)progressValue{
    progressValue = MAX( MIN(progressValue, 1.0), 0.0);
     _progressValue = progressValue;
    CGFloat width = self.bounds.size.width;
    frontFillBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f) radius:(CGRectGetWidth(self.bounds)-2.0)/2.f startAngle:-0.25*2*M_PI endAngle:(2*M_PI)*progressValue - 0.25*2*M_PI clockwise:YES];
    frontFillLayer.path = frontFillBezierPath.CGPath;
    
    if (progressValue == 1) {
       if ([self.delegate respondsToSelector:@selector(progressViewOver:)]) {
           [self.delegate progressViewOver:self];
       }
       return;
   }
}
- (CGFloat)progressValue
{
    return _progressValue;
}
@end


@interface FBAssetsHandlerProgressView()<FBProgressViewDelegate>

@end
@implementation FBAssetsHandlerProgressView{
    FBProgressView *progressView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexString:@"#000000" alpha:0.85];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGFloat height = 150;
    CGFloat width = 150;
    return CGSizeMake(width, height);
}

-(void)setupUI{
    progressView = [[FBProgressView alloc]initWithFrame:CGRectMake(100, 100, 64, 64)];
    progressView.delegate = self;
    [self addSubview:progressView];
    
    self.label = [[UILabel alloc] init];
    self.label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    
    self.detailsLabel = [[UILabel alloc] init];
    self.detailsLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.detailsLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    self.detailsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.detailsLabel];
       
}
-(void)setupUILayout{
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(17);
        make.size.mas_equalTo(CGSizeMake(64, 64));
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressView.mas_bottom).offset(12);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.detailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.label.mas_bottom).offset(4);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

- (void)changeProgressValue:(CGFloat)progress{
    //NSLog(@"updateProgressHUBp :%f -- %@",progress, [NSString stringWithFormat:@"%.0f%%",progress*100]);
    
    progressView.progressValue = progress;
    progressView.contentText=[NSString stringWithFormat:@"%.0f%%",progress*100];
}

-(void)progressViewOver:(FBProgressView *)progressView {
    //NSLog(@"value为1");
}
@end
