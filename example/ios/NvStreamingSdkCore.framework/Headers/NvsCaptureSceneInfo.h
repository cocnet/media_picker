//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2021. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 07. 2021
//   Author:        NewAuto video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \if ENGLISH
 *  \brief clip data
 *  \else
 *  \brief 片段数据
 *  \endif
 *  \since 3.2.0
 */
NVS_EXPORT @interface NvsClipData : NSObject

@property (nonatomic) NSString* mediaPath;    //!< \if ENGLISH media path \else 资源路径 \endif

@end

/*! \if ENGLISH
*   \brief Capture scene informations.
*   \else
*   \brief 拍摄场景资源信息。
*   \endif
*   \since 3.2.0
*/

NVS_EXPORT @interface NvsCaptureSceneInfo : NSObject

@property (nonatomic, strong) NSMutableArray<NvsClipData *> *backgroundClipArray;
@property (nonatomic, strong) NSMutableArray<NvsClipData *> *foregroundClipArray;

@end
