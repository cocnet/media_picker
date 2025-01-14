//
//  JYCollectionViewImageTool.m
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/22.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYCollectionViewImageTool.h"

static NSInteger kJYCollectionViewImageToolMaxImager = 30;

static JYCollectionViewImageTool *instance;

@interface JYCollectionViewImageTool()

@property (nonatomic,strong)NSMutableDictionary *imageDic;//由唯一值记录

@property (nonatomic,strong)NSMutableArray *indexArray;//记录存储的顺序

@end

@implementation JYCollectionViewImageTool

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [JYCollectionViewImageTool new];
    });
    return instance;
}

//从缓存里取
- (UIImage *)getImageForKey:(NSString *)string{
    if([[self.imageDic allKeys] containsObject:string])
    {
        return [self.imageDic valueForKey:string];
    }else{
        return nil;
    }
}

//存到缓存容器中去
- (void)saveImage:(UIImage *)image key:(NSString *)string{
    if(!image){
        return;
    }
    if (self.indexArray.count >= kJYCollectionViewImageToolMaxImager){
        [self.imageDic removeObjectForKey:self.indexArray[0]];
        [self.indexArray removeObjectAtIndex:0];
        [self.indexArray addObject:string];
        [self.imageDic setObject:image forKey:string];
    } else {
        [self.indexArray addObject:string];
        [self.imageDic setObject:image forKey:string];
    }
}

- (void)removeAllData{
    self.imageDic = nil;
    self.indexArray = nil;
}

-(NSMutableDictionary *)imageDic{
    if (!_imageDic){
        _imageDic = [NSMutableDictionary new];
    }
    return _imageDic;
}

- (NSMutableArray *)indexArray{
    if (!_indexArray){
        _indexArray = [NSMutableArray new];
    }
    return _indexArray;
}

@end
