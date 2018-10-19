//
//  AmazingWall.h
//  Camera
//
//  Created by jerrysun on 2016/10/26.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DraperWall : UIView
@property (nonatomic ,assign) NSInteger normalShowCount;
- (void)addFreshData:(NSArray *)array;
- (void)appendingData:(NSArray *)array;
- (void)reloadData;
@end
