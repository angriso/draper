//
//  DraperBox.h
//  DynamicBehavior
//
//  Created by jerrysun on 16/5/23.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DraperBox : UIView
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) void (^didTapDraper)(NSInteger index);
-(void)configureWithData:(NSMutableArray *)array;
@end
