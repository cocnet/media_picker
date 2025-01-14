//
//  FBBaseTypeModel.m
//  multi_image_picker
//
//  Created by 杨志豪 on 3/21/22.
//

#import "FBBaseTypeModel.h"

@implementation FBBaseTypeModel

+ (FBBaseTypeModel *) createForNumber:(NSNumber *)number isEditImg:(BOOL)isEditImg{
    FBBaseTypeModel *model = [FBBaseTypeModel new];
    model.type = number.intValue;
    switch (model.type) {
        case FBClipType_Clip:
            model.typeName = @"剪辑";
            model.typeImage = @"type_clip";
            break;
        case FBClipType_Music:
            model.typeName = @"音乐";
            model.typeImage = @"type_music";
            break;
        case FBClipType_Filter:
            model.typeName = @"滤镜";
            model.typeImage = @"type_filter";
            break;
        case FBClipType_Caption:
            model.typeName = isEditImg ? @"文字" : @"文字";
            model.typeImage = @"type_caption";
            break;
        case FBClipType_Sticker:
            model.typeName = @"贴纸";
            model.typeImage = @"type_sticker";
            break;
        case FBClipType_Background:
            model.typeName = @"背景";
            model.typeImage = @"type_background";
            break;
        case FBClipType_Back:
            model.typeName = @"返回";
            model.typeImage = @"type_back";
            break;
        case FBClipType_Adjust:
            model.typeName = @"调整";
            model.typeImage = @"type_adjust";
            break;
        case FBClipType_Cut:
            model.typeName = @"分割";
            model.typeImage = @"type_cup";
            break;
        case FBClipType_Speed:
            model.typeName = @"变速";
            model.typeImage = @"type_speed";
            break;
        case FBClipType_Delete:
            model.typeName = @"删除";
            model.typeImage = @"type_delete";
            break;
        case FBClipType_Save:
            model.typeName = @"保存";
            model.typeImage = @"type_done";
            break;
        case FBClipType_Short:
            model.typeName = @"排序";
            model.typeImage = @"type_short";
            break;
        case FBClipType_Paint:
            model.typeName = @"画笔";
            model.typeImage = @"type_paint";
            break;
        case FBClipType_Mosaic:
            model.typeName = @"马赛克";
            model.typeImage = @"type_mosaic";
            break;
        case FBClipType_Cropping:
            model.typeName = @"裁剪";
            model.typeImage = @"type_adjust";
            break;
        default:
            break;
    }
    return model;
}

@end
