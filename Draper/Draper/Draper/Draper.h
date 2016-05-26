//
//  Draper.h
//  DynamicBehavior
//
//  Created by jerrysun on 16/5/20.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DraperDelegate;

@interface Draper : UIView

@property (nonatomic ,weak) id <DraperDelegate> delegate;

@property (nonatomic ,assign) CGPoint originCenter;
@property (nonatomic ,strong) UIImageView *imageView;
@property (nonatomic ,strong) UILabel *titleLab;
@end

@protocol DraperDelegate <NSObject>

// 开始拖动
-(void)draperBeginDrag:(Draper *)draper;
// 正在拖动
-(void)draperDraging:(Draper *)draper;
// 开始移除
-(void)draperBeginMoveOut:(Draper *)draper;
// 完全移除
-(void)draperMoveOut:(Draper *)draper;
// 开始归位
-(void)draperRegress:(Draper *)draper;

-(void)draperDidTap:(Draper *)draper;

@end