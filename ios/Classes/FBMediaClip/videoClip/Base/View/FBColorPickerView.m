//
//  FBColorPickerView.m
//  multi_image_picker
//
//  Created by amzwin on 2022/4/18.
//

#import "FBColorPickerView.h"
#import <Masonry/Masonry.h>
#import "UIColor+NvColor.h"
#import "TZImagePickerController.h"

@interface FBColorPickerView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong) UICollectionView *colorCollectionView;
@property(nonatomic,strong) NSArray *colorArray;
@end
@implementation FBColorPickerView
{
   
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.colorArray = [[self class] allColors];
        
        UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc] init];
        layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout1.itemSize =  [FBColorPickerCCell itemSize];
        layout1.minimumLineSpacing =  12;
        layout1.minimumInteritemSpacing = 0;
        layout1.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        self.colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout1];
        self.colorCollectionView.delegate = self;
        self.colorCollectionView.dataSource = self;
        self.colorCollectionView.backgroundColor = [UIColor clearColor];
        self.colorCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.colorCollectionView];
        [self.colorCollectionView registerClass:[FBColorPickerCCell class] forCellWithReuseIdentifier:[FBColorPickerCCell identifier]];
        [self.colorCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

+(NSArray<NSString*>*)allColors{
     NSArray<NSString*> *colors =  @[@"#FFFFFF", @"#000000", @"#C9C9C9", @"#FF786A", @"#FFA79D", @"#FF915C",
                   @"#FFBF95",@"#FFCF63",@"#FFEFB3",@"#BFDE91",@"#E0F5C3",@"#7BDCD5",
                                     @"#BFEEE4",@"#8DC8FF",@"#B6E3FF",@"#A592F2",@"#C4C3FF",@"#F4B6F0",
                                     @"#FFDBEF",
                   ];
    return colors;
}

- (void)fillViewContent:(NSString*)selColorString{
    _curSelectedColor = selColorString;
    [self.colorCollectionView reloadData];
}
- (NSString*)updateSelectedIndex:(NSInteger)index{
    if(index + 1 > self.colorArray.count) return nil;
    
    _curSelectedColor = [self.colorArray objectAtIndex:index];
    [self.colorCollectionView reloadData];
    
    return  _curSelectedColor;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBColorPickerCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FBColorPickerCCell identifier] forIndexPath:indexPath];
    NSString* color = [self.colorArray objectAtIndex:indexPath.row];
    [cell fillCellContent:self.colorArray[indexPath.item] isSelected:color == _curSelectedColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //todo 再次点击是否要取消 ?
    NSInteger index = 0;
    for (NSString *model in self.colorArray) {
        if(index == indexPath.row){
            _curSelectedColor = model;
        }else{
           
        }
        index++;
    }
    [collectionView reloadData];
    
    if(self.colorPicked) self.colorPicked(_curSelectedColor);
}

@end


@implementation FBColorPickerCCell{
    UIView *colorView;
    UIImageView *imageView;
}
+(NSString*)identifier{
    return NSStringFromClass(self);
}

+(CGSize)itemSize{
    return CGSizeMake(28, 28);
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 14;
        self.layer.borderColor = [UIColor nv_colorWithHexString:@"#8D93A6" alpha:0.2].CGColor;
        self.layer.borderWidth = 1;
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

- (void)fillCellContent:(NSString*)colorString isSelected:(BOOL)isSelected{
    colorView.backgroundColor = [UIColor colorWithHexString:colorString];
    [imageView setHidden:!isSelected];
}

-(void)setupUI{
    colorView = [[UIView alloc] init];
    colorView.clipsToBounds = YES;
    colorView.layer.cornerRadius = 13;
    [self addSubview:colorView];
    [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(1, 1, 1, 1));
    }];
    
    imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.image = [UIImage tz_imageNamedFromMyBundle:@"color_picker_sel_icon"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
}

-(void)setupUILayout{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

@end
