//
//  Derivator.m
//
//  Created by jerrysun on 2017/8/5.
//  Copyright © 2017年 Niang. All rights reserved.
//

#import "Derivator.h"

@interface Derivator ()

@end
@implementation Derivator
+ (Derivator *)sample:(double)value time:(double)time{
    Derivator *der = [Derivator new];
    der.time = time;
    der.value = value;
    return der;
}
- (void)addValue:(double)value limitTime:(double)time
{
    if (!_samples) {
         _samples = [NSMutableArray array];
    }
    CFTimeInterval currentTime = CACurrentMediaTime();
    
    [_samples addObject:[Derivator sample:value time:currentTime]];
    
    // Remove samples older than our sample time - 1 seconds "time"
    int i = 0, count = (int)_samples.count;
    while (i < count - 2)
    {
        if ((currentTime - _samples[i].time) > time)
        {
            [_samples removeObjectAtIndex:0];
            i -= 1;
            count -= 1;
        }
        else
        {
            break;
        }
        
        i += 1;
    }
}
- (double)ascent{
    if (_samples.count<2) {
        return 0;
    }
    double sum = 0;
    Derivator *der = [_samples firstObject];
    for (int i = 1; i<_samples.count; i++) {
        double valueDetal = _samples[i].value - der.value;
        double time = _samples[i].time - der.time;
        sum += valueDetal/time;
    }
    double asc = sum/(_samples.count-1);
    return asc;
}
+ (CGFloat)percentForPageWithDistance:(CGFloat)distance offset:(CGFloat)offset
{
    CGFloat divisor = offset/distance;
    
    int intparty = (int)divisor;
    
    CGFloat percent = divisor - (float)intparty;
    
    CGFloat asc = [Derivator scrollerDirectionWith:offset];
    
    if (asc>0) {// <-----
        if (percent==0.0) {
            percent = 1.0;
        }
    }
    
    return percent;
}
+ (NSInteger)scrollerDirectionWith:(CGFloat)offset{
    static Derivator *derivator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        derivator = [[Derivator alloc] init];
    });
    [derivator addValue:offset limitTime:0.35];
    double asc = [derivator ascent];
    return asc;
}

@end
