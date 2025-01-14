//
//  FBSelectAssetsPreviewVew.m
//  FBVideoClip
//
//  Created by amzwin on 2022/3/18.
//

#import "FBSelectAssetsPreviewVew.h"
#import <Masonry/Masonry.h>
#import "FBSelectAssetsPreviewCCell.h"
#import "UIView+frame.h"
#import "FBVideoCLipHeader.h"
#import "TZImagePickerController.h"

@interface FBSelectAssetsPreviewVew()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UIView      *bgView;
@property (nonatomic,strong) UILabel     *titleLab;
@property (nonatomic,strong) UICollectionView *assetCollectionView;
@property (nonatomic,strong) UIButton *thumeButton;
//@property (nonatomic,strong) UIImageView *thumeImageView;
//@property (nonatomic,strong) UILabel *thumeLabel;
@property (nonatomic,strong) UIButton *onClickVideoButton;
@property (nonatomic,strong) UIButton *nextButton;

@property(nonatomic,strong) UILongPressGestureRecognizer *longPress;
@end

@implementation FBSelectAssetsPreviewVew
{
    bool isShow;
    NSMutableArray <PHAsset *>* curList;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1f1f1f"];
        isShow = NO;
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

+(CGFloat)height{
    return 204;
}
-(void)show{
    if(isShow) return;
    isShow = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.y = [UIScreen mainScreen].bounds.size.height - [[self class] height];
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hide{
    isShow = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.y = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)fillContent:(NSMutableArray <PHAsset *>*)selectVideoArr isShowGenVideoButton:(BOOL)isShowGenVideoButton{
    curList = selectVideoArr;
    TZImagePickerController *nav = [self findViewController].navigationController;
    self.titleLab.text = [NSString stringWithFormat:@"长按素材可排序(%ld/%ld)",curList.count, nav.maxImagesCount];
    [self.nextButton setTitle: [NSString stringWithFormat:@"下一步(%ld)",curList.count] forState:UIControlStateNormal];
    [self.assetCollectionView reloadData];
    
    self.onClickVideoButton.hidden = !isShowGenVideoButton;
    
    //自动滑动到最后
    if(selectVideoArr && selectVideoArr.count){
        [self.assetCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectVideoArr.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(curList == nil) return 0;
    return [curList count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FBSelectAssetsPreviewCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FBSelectAssetsPreviewCCell identifier] forIndexPath:indexPath];
    weakify(self);
    cell.deleteSeletedImage = ^(PHAsset* model){
        strongify(self);
        [self deleteImage:model];
    };
    PHAsset *model = [curList objectAtIndex:indexPath.row];
    [cell fillCellContent:model];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate){
        PHAsset *model = [curList objectAtIndex:indexPath.row];
        [self.delegate previewItem:self model:model];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [FBSelectAssetsPreviewCCell itemSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//    [curList exchangeObjectAtIndex:sourceIndexPath.row  withObjectAtIndex: destinationIndexPath.row ];
    
    id objc = [curList objectAtIndex:sourceIndexPath.item];
    [curList removeObject:objc];
    [curList insertObject:objc atIndex:destinationIndexPath.item];
    [collectionView reloadData];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateAlbumDataSource:fromIndex:toIndex:)]){
        [self.delegate updateAlbumDataSource:self fromIndex:sourceIndexPath.item toIndex:destinationIndexPath.item];
    }
}

#pragma mark -- Event response
#pragma mark 删除图片
-(void)deleteImage:(PHAsset*)model{
//    NSInteger index = [curList indexOfObject:model];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteItem:model:)]){
        [self.delegate deleteItem:self model:model];
    }
//    [self.assetCollectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]];
}

- (void)longPressMoving:(UILongPressGestureRecognizer *)longPress{
    switch (_longPress.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *selectIndexPath = [self.assetCollectionView indexPathForItemAtPoint:[_longPress locationInView:self.assetCollectionView]];
            // 找到当前的cell
            FBSelectAssetsPreviewCCell *cell = (FBSelectAssetsPreviewCCell *)[self.assetCollectionView cellForItemAtIndexPath:selectIndexPath];
            //拽起变大动画效果
            [UIView animateWithDuration:0.25 animations:^{
                [cell setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
            }];
           //开始移动
            [self.assetCollectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            //更新移动的位置
            CGPoint p = [longPress locationInView:_longPress.view];
            //NSLog(@"%f --  %f", x.x, x.y);
            //x.y = 30;
            p.y = self.assetCollectionView.y-10;
            [self.assetCollectionView updateInteractiveMovementTargetPosition:p];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            //结束移动
            [self.assetCollectionView endInteractiveMovement];
            break;
        }
        default: [self.assetCollectionView cancelInteractiveMovement];
            break;
    }
}

-(void)oneStep:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(createVideoOneStep:)]){
        [self.delegate createVideoOneStep:self];
    }
}

-(void)goNext:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(nextStep:)]){
        [self.delegate nextStep:self];
    }
}
-(void)switchAllowPickingOriginalPhoto:(id)sender{
    self.isThumSelected = !self.isThumSelected;
    [self.thumeButton setSelected:self.isThumSelected];
    if(self.delegate && [self.delegate respondsToSelector:@selector(didAllowPickingOriginalPhoto:isSelected:)]){
        [self.delegate didAllowPickingOriginalPhoto:self isSelected:self.isThumSelected];
    }
    
}

#pragma mark -- Private methods
#pragma mark 初始化
- (void)setupUI {
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textColor= [UIColor colorWithHex:0xFFFFFF alpha:0.6];
    self.titleLab.text = @"长按素材可排序";
    self.titleLab.font=[UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [self addSubview:self.titleLab];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.assetCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.assetCollectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
    self.assetCollectionView.backgroundColor = [UIColor clearColor];
    self.assetCollectionView.dataSource = self;
    self.assetCollectionView.delegate = self;
    self.assetCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.assetCollectionView.showsHorizontalScrollIndicator = NO;
    self.assetCollectionView.alwaysBounceHorizontal = YES;
    [self.assetCollectionView registerClass:[FBSelectAssetsPreviewCCell class] forCellWithReuseIdentifier:[FBSelectAssetsPreviewCCell identifier]];
    [self addSubview:self.assetCollectionView];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMoving:)];
    [self.assetCollectionView addGestureRecognizer:_longPress];
    
    self.thumeButton = [[UIButton alloc] init];
    [self.thumeButton setImage:[UIImage tz_imageNamedFromMyBundle:@"thum_uncheck_icon"] forState:UIControlStateNormal];
    [self.thumeButton setImage:[UIImage tz_imageNamedFromMyBundle:@"thum_checked_icon"] forState:UIControlStateSelected];
    [self.thumeButton setTitle:@"原图" forState:UIControlStateNormal];
    self.thumeButton.titleLabel.font =[UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.thumeButton.titleLabel.textColor = [UIColor whiteColor];
    //self.thumeButton.titleLabel.layer.transform = CATransform3DMakeScale(1, 1.1, 0);
    self.thumeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.thumeButton setImageEdgeInsets:UIEdgeInsetsMake(8, -10, 8, 10)];
    [self.thumeButton setTitleEdgeInsets:UIEdgeInsetsMake(1, -3, -1, 3)];
    [self.thumeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.thumeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.thumeButton addTarget:self action:@selector(switchAllowPickingOriginalPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.thumeButton setHidden:YES];
    [self addSubview:self.thumeButton];
    
//    UITapGestureRecognizer *thumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchAllowPickingOriginalPhoto:)];
//    self.thumeImageView = [[UIImageView alloc] init];
//    self.thumeImageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.thumeImageView.image = [UIImage imageNamed:@"thum_uncheck_icon"];
//    self.thumeImageView.highlightedImage = [UIImage imageNamed:@"thum_checked_icon"];
//    [self.thumeImageView setHighlighted:!!self.isThumSelected];
//    self.thumeImageView.userInteractionEnabled = YES;
//    self.thumeImageView.backgroundColor = [UIColor blackColor];
//    [self.thumeImageView addGestureRecognizer:thumTap];
//    [self addSubview:self.thumeImageView];
//
//    self.thumeLabel = [[UILabel alloc] init];
//    self.thumeLabel.textColor= [UIColor whiteColor];
//    self.thumeLabel.text = @"原图";
//    self.thumeLabel.font=[UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
//    self.thumeLabel.userInteractionEnabled = YES;
//    [self.thumeLabel addGestureRecognizer:thumTap];
//    [self addSubview:self.thumeLabel];
    
    self.onClickVideoButton = [[UIButton alloc] init];
    [self.onClickVideoButton setImage:[UIImage tz_imageNamedFromMyBundle:@"gen_video_one_step"] forState:UIControlStateNormal];
    [self.onClickVideoButton addTarget:self action:@selector(oneStep:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.onClickVideoButton];
    
    self.nextButton = [[UIButton alloc] init];
    self.nextButton.backgroundColor = [UIColor colorWithHex:0x198CFE];
    self.nextButton.layer.cornerRadius = 18.0f;
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.nextButton setImage:@"" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self addSubview:self.nextButton];
}

-(void)setupUILayout{
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(12);
    }];
    
    [self.assetCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.top.equalTo(self.titleLab.mas_bottom).offset(12);
        make.height.mas_equalTo([FBSelectAssetsPreviewCCell itemSize].height);
    }];
    
    [self.thumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.assetCollectionView.mas_bottom).offset(20);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(100, 36));
    }];
    
//    [self.thumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.thumeImageView.mas_right).offset(9);
//        make.height.mas_equalTo(20);
//        make.top.equalTo(self.thumeImageView.mas_top);
//    }];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-12);
        make.size.mas_equalTo(CGSizeMake(98, 36));
        make.top.equalTo(self.assetCollectionView.mas_bottom).offset(20);
    }];
    
    [self.onClickVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(110, 36));
        make.right.equalTo(self.nextButton.mas_left).offset(-12);
        make.top.equalTo(self.assetCollectionView.mas_bottom).offset(20);
    }];
}
@end
