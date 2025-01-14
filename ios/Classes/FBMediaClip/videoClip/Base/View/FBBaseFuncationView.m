//
//  FBBaseFuncationView.m
//  multi_image_picker
//
//  Created by 杨志豪 on 3/21/22.
//

#import "FBBaseFuncationView.h"
#import "FBVideoCLipHeader.h"
#import "FBBaseFuncationViewColoCollectionViewCell.h"
#import "TZImagePickerController.h"



@interface FBBaseFuncationView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic,strong) NSArray<FBBaseTypeModel *> * typeArray;
@end

@implementation FBBaseFuncationView

+(CGFloat)height{
    return 54;
}

///这里的typeArray要传FBClipType类型
+ (FBBaseFuncationView*) initFactionView:(NSArray<NSNumber*> *)typeArray isEditImg:(BOOL)isEditImg{
    FBBaseFuncationView *funcationView = [[FBBaseFuncationView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [FBBaseFuncationView height])];
    NSMutableArray<FBBaseTypeModel *> *array = [NSMutableArray new];
    for (NSNumber *number in typeArray) {
        [array addObject:[FBBaseTypeModel createForNumber:number isEditImg:isEditImg]];
    }
    funcationView.typeArray = [array copy];
    return funcationView;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //设置其边界
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[FBBaseFuncationViewColoCollectionViewCell class] forCellWithReuseIdentifier:@"FBBaseFuncationViewColoCollectionViewCell"];
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

-(void)setTypeArray:(NSArray<FBBaseTypeModel *> *)typeArray{
    _typeArray = typeArray;
    [self.collectionView reloadData];
}
#pragma mark -CollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate selectType:self.typeArray[indexPath.row].type];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(!self.typeArray) return 0;
    return self.typeArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBBaseFuncationViewColoCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"FBBaseFuncationViewColoCollectionViewCell" forIndexPath:indexPath];
    cell.mainTitleLabel.text = [NSString stringWithFormat:@"%@",self.typeArray[indexPath.row].typeName];
    [cell.mainImageView setImage:[UIImage tz_imageNamedFromMyBundle:self.typeArray[indexPath.row].typeImage]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.typeArray) return CGSizeZero;
    return CGSizeMake(JY_SCREAN_WIDTH / self.typeArray.count, [[self class] height]);
}

@end
