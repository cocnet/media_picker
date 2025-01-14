//
//  FBMeisheSourceTool.m
//  multi_image_picker
//
//  Created by 杨志豪 on 4/28/22.
//

#import "FBMeisheSourceTool.h"
#import "FBVideoCLipHeader.h"
#import <YYModel/YYModel.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <AFNetworking/AFNetworking.h>
#import "JYHandleFile.h"
#import <FCFileManager/FCFileManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSBundle+TZImagePicker.h"
static FBMeisheSourceTool *instance;


@interface FBMeisheSourceTool()

@property (nonatomic,strong) FBResourceModel *model;

@end

@implementation FBMeisheSourceTool




+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [FBMeisheSourceTool new];
        SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
        [[SDImageCodersManager sharedManager] addCoder:webPCoder];
        [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [instance loadlocationJson];
        
    });
    return instance;
}

- (void)updateNetWorkSource {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSTimeInterval time;
    if (@available(iOS 13.0, *)) {
        time = [[NSDate now] timeIntervalSince1970];
    } else {
        time = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    }
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://fb-cdn.fanbook.mobi/fanbook/meishe/SDKLib/meishe.json?ts=%ld",time]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSString *userDataPath = [JYHandleFile getSDKDataDirectory];
    NSString *path = [[JYHandleFile getSDKDataDirectory] stringByAppendingPathComponent:@"meisheNetWorking.json"];
    if([FCFileManager existsItemAtPath:path]){
        [FCFileManager removeItemAtPath:path];
    }
    @weakify(self);
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *userDataPath = [JYHandleFile getSDKDataDirectory];
        NSString *path = [[JYHandleFile getSDKDataDirectory] stringByAppendingPathComponent:@"meisheNetWorking.json"];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        @strongify(self);
        if (!error) {
             if([FCFileManager existsItemAtPath:filePath.path]){
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                if (data && data.length > 0) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    FBResourceModel *listModel = [FBResourceModel yy_modelWithJSON:dict];
                    if(listModel.filterArray && listModel.filterArray.count){
                        //简单校验一下数据完整性
                        self.model = listModel;
                    }
                }
            }
          }
    }];
    [downloadTask resume];
}

- (FBResourceModel *)loadAllSourseData {
    return self.model;
}


- (void)loadlocationJson {
    NSString *str = [[NSBundle tz_imagePickerBundle] pathForResource:@"meishe" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:str];
     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    FBResourceModel *listModel = [FBResourceModel yy_modelWithJSON:dict];
    self.model = listModel;
}
@end
