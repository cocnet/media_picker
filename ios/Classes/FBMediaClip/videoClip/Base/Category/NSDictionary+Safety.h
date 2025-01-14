//
//  NSDictionary+Safety.h
//  HiTao
//
//
//  Created by amzwin on 2022/4/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (Safety)
-(id)safe_objectForKey:(id)aKey;
-(NSString*)safe_stringForKey:(id)aKey;
-(NSInteger)safe_integerForKey:(id)aKey;
-(long long int)safe_longlongintForKey:(id)aKey;
-(CGFloat)safe_floatForKey:(id)aKey;
@end

@interface NSMutableDictionary (Safety)
-(void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey;
-(void)safe_setValue:(id)value forKey:(NSString *)key;
@end
