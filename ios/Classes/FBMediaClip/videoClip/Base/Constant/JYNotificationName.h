//
//  JYNotificationName.h
//  VideoClip
//
//  Created by yzh on 2019/4/28.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * JYNotificationName;

//openurl导入了音频
extern JYNotificationName const JYNotificationNameOpenURLAudioFile;

extern JYNotificationName const JYNotificationNameAudioFileNumChange;

extern JYNotificationName const JYNotificationNameDraftNumChange;

//处理视频完成，比如增加、删除
extern JYNotificationName const JYNotificationNameEditVideoComplete;
extern JYNotificationName const JYNotificationNameVideoFileNumChange;

//处理登陆成功
extern JYNotificationName const JYNotificationNameLoginSuccess;

extern JYNotificationName const JYNotificationNamePromotionPaySuccess;

//处理支付变化
extern JYNotificationName const JYNotificationNamePayStatusChange;

//选择音乐列表时，未选中直接返回
extern JYNotificationName const JYNotificationNameSelectMusicVCBack;

//从服务器请求是否开屏显示广告结束
extern JYNotificationName const JYNotificationNameAdsCheckingFinished;

extern JYNotificationName const JYNotificationNameChangeToHome;

extern JYNotificationName const JYNotificationNameVideoEditModuleChange;

extern JYNotificationName const JYNotificationNameVideoEditOperationChange;

extern JYNotificationName const JYNotificationNameVideoEditModuleMusicItemSelectedChange;

extern JYNotificationName const JYNotificationNameVideoEditModuleCaptionItemSelectedChange;

extern JYNotificationName const JYNotificationNameVideoMusicUnfoldStatusChange;

extern JYNotificationName const JYNotificationNameVideoCaptionUnfoldStatusChange;

extern JYNotificationName const JYNotificationNameSaveToDraft;

extern JYNotificationName const JYNotificationNameRictViewMoiveStart;

extern JYNotificationName const JYNotificationNameRictViewMoiveEnd;

extern JYNotificationName const JYNotificationNameUpdateClip;

extern JYNotificationName const JYNotificationNamereseVideo;
