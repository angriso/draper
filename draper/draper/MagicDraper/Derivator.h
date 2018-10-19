//
//  Derivator.h
//
//  Created by jerrysun on 2017/8/5.
//  Copyright © 2017年 Niang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Derivator : NSObject
@property (nonatomic ,assign) double time;
@property (nonatomic ,assign) double value;
@property (nonatomic ,strong) NSMutableArray <Derivator *>*samples;
- (void)addValue:(double)value limitTime:(double)time;
- (double)ascent;
+ (CGFloat)percentForPageWithDistance:(CGFloat)distance offset:(CGFloat)offset;
@end
