//
//  FBClipFuncationVIew.m
//  multi_image_picker
//
//  Created by 杨志豪 on 4/21/22.
//

#import "FBClipFuncationVIew.h"
#import "FBClipFuncationViewColoCollectionViewCell.h"
#import "NSBundle+TZImagePicker.h"
#import "TZImagePickerController.h"

@interface FBClipFuncationVIew()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSArray<NSNumber *> *dissableArray;
@end

@implementation FBClipFuncationVIew

//这里的typeArray要传FBClipType类型
+ (FBClipFuncationVIew*) initFactionView:(NSArray<NSNumber*> *)typeArray {
    FBClipFuncationVIew *funcationView = [[NSBundle tz_imagePickerBundle] loadNibNamed:@"FBClipFuncationVIew" owner:self options:nil].lastObject;
    NSMutableArray<FBBaseTypeModel *> *array = [NSMutableArray new];
    for (NSNumber *number in typeArray) {
        [array addObject:[FBBaseTypeModel createForNumber:number isEditImg:NO]];
    }
    funcationView.typeArray = [array copy];
    return funcationView;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FBClipFuncationViewColoCollectionViewCell" bundle:[NSBundle tz_imagePickerBundle]] forCellWithReuseIdentifier:@"FBClipFuncationViewColoCollectionViewCell"];
}

-(void)updateDissableArray:(NSArray<NSNumber *> *)dissableArray {
    self.dissableArray = dissableArray;
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
    FBClipFuncationViewColoCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"FBClipFuncationViewColoCollectionViewCell" forIndexPath:indexPath];
    cell.mainTitleLabel.text = [NSString stringWithFormat:@"%@",self.typeArray[indexPath.row].typeName];
    [cell.mainImageView setImage:[UIImage tz_imageNamedFromMyBundle:self.typeArray[indexPath.row].typeImage]];
    [cell setDissable:NO];
    if (self.dissableArray && self.dissableArray.count == self.typeArray.count) {
        if (self.dissableArray[indexPath.row] == @1) {
            [cell setDissable:YES];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.typeArray) return CGSizeZero;
    return CGSizeMake(JY_SCREAN_WIDTH / self.typeArray.count, self.height);
}


@end
