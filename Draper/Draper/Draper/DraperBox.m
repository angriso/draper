//
//  DraperBox.m
//  DynamicBehavior
//
//  Created by jerrysun on 16/5/23.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import "DraperBox.h"
#import "Draper.h"
#import "UIImage+Blur.h"



#define SCREEN_HEIGHT   ((float)[[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH    ((float)[[UIScreen mainScreen] bounds].size.width)



@interface DraperBox ()<DraperDelegate>

@property (nonatomic ,strong) NSMutableArray <Draper *>*draperViewArray;
@property (nonatomic ,assign) NSInteger draperIndex;
@property (nonatomic ,assign) CGRect originFrame;
@property (nonatomic ,strong) UIImageView *blurImageView;
@property (nonatomic ,assign) CGFloat alphaGrad;
@end

@implementation DraperBox{
    
}

static const int SHOW_COUNT = 3; //显示Cell的个数

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        _alphaGrad = 0.1*(10/SHOW_COUNT);
        _dataArray = [NSMutableArray  array];
        _draperViewArray = [NSMutableArray array];
        _blurImageView   = [[UIImageView alloc] init];
        [self addSubview:_blurImageView];
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    [self freshFront];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    _blurImageView.frame = self.bounds;
}


-(void)configureWithData:(NSMutableArray *)array{
    
    _dataArray = array;
    
    // 不管有多少数据，只加载这么多重用
    
    for (int i = 0; i<SHOW_COUNT*2+1; i++) {
        CGSize size = CGSizeMake(300, 380);
        CGSize boze = [UIScreen mainScreen].bounds.size;
        Draper *draper = [[Draper alloc] initWithFrame:CGRectMake((boze.width-size.width)/2,(boze.height-size.height)/2,size.width ,size.height)];
        self.originFrame =  draper.frame;
        draper.originCenter = CGPointMake(_originFrame.origin.x+_originFrame.size.width/2, _originFrame.origin.y+_originFrame.size.height/2);
        draper.delegate = self;
        [_draperViewArray addObject:draper];
    }
    
    NSArray *prefixs = [self.draperViewArray subarrayWithRange:NSMakeRange(0, SHOW_COUNT*2)];
    
    for (NSInteger i = prefixs.count-1; i>=0; i--) {
        Draper *draper = [prefixs objectAtIndex:i];
        [self addSubview:draper];
    }
    
    [self managerDraperAppear];
}


#pragma mark delegate  --------------
-(void)draperDraging:(Draper *)draper{
    
}

-(void)draperBeginDrag:(Draper *)draper{
    
    
    NSArray *prefixs = [self.draperViewArray subarrayWithRange:NSMakeRange(0, SHOW_COUNT)];
    [UIView animateWithDuration:0.7 animations:^{
        for (int i = 0; i<prefixs.count-1; i++) {
            Draper *draper = [prefixs objectAtIndex:i+1];
            draper.alpha = 1 -  i*_alphaGrad;
        }
    }];
    
    
}
-(void)draperRegress:(Draper *)draper{
    NSArray *prefixs = [self.draperViewArray subarrayWithRange:NSMakeRange(0, SHOW_COUNT)];
    [UIView animateWithDuration:0.7 animations:^{
        for (int i = 0; i<prefixs.count; i++) {
            Draper *draper = [prefixs objectAtIndex:i];
            draper.alpha = 1 -  i*_alphaGrad;
        }
    }];
}

-(void)draperBeginMoveOut:(Draper *)draper{
    
    
    [_draperViewArray removeObject:draper];
    {
        _draperIndex++;
        if (_draperIndex == _dataArray.count) {
            _draperIndex = 0;
        }
        
        //NSArray *images = self.freshModelsInRange(_draperIndex,SHOW_COUNT);
        
        NSArray *images = [self data:self.dataArray itemIndex:_draperIndex shou:SHOW_COUNT];
        
        
        if (self.draperViewArray.count<=SHOW_COUNT) {
            // if  clyle
            // else  reuse
        }
        
        NSArray *fontThree = [self.draperViewArray subarrayWithRange:NSMakeRange(0, SHOW_COUNT)];
        Draper *lastDraper = [self.draperViewArray objectAtIndex:SHOW_COUNT*2-1];
        
        [self insertSubview:lastDraper aboveSubview:_blurImageView];
        
        [self styleDraper:fontThree withImages:images];
    
    }
    [_draperViewArray addObject:draper];
    
}
-(void)draperMoveOut:(Draper *)draper{
    
}
-(void)draperDidTap:(Draper *)draper{
    self.didTapDraper(_draperIndex);
}


-(void)adjustScaleFrame:(Draper *)draper index:(NSInteger)i{
    
    draper.titleLab.text = [@(i+_draperIndex) stringValue];
    draper.transform = CGAffineTransformIdentity;  //这个地方好坑呀，一定要执行执行这一步
    draper.frame = _originFrame;
    CGFloat scale =  1 - i*0.05;
    draper.transform =  CGAffineTransformScale(draper.transform, scale, scale);
    draper.frame = CGRectMake(draper.frame.origin.x, _originFrame.origin.y, draper.frame.size.width, draper.frame.size.height);
    draper.alpha = 1 -  i*_alphaGrad;
    draper.transform = CGAffineTransformTranslate(draper.transform, 0, -5*i);
}


-(void)styleDraper:(NSArray *)drapers withImages:(NSArray *)images{
    
    [drapers enumerateObjectsUsingBlock:^(Draper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageNamed:[images objectAtIndex:idx]];
        obj.imageView.image = image;
    }];

    [self style:drapers];
    
}



-(void)style:(NSArray *)drapers{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
        UIImage *image = [((Draper*)[drapers firstObject]).imageView.image blurImageWithBlur:0.6 exclusionPath:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            _blurImageView.image = image;
        });
    });
    
    for (int i = 0; i<drapers.count; i++) {
        
        Draper *draper = [drapers objectAtIndex:i];
        // 如果最后一个加上了动画，当view重用的时候就会看到view从下面飞上来的过程
        if (i!=drapers.count-1){
            [UIView animateWithDuration:0.5 animations:^{
                [self adjustScaleFrame:draper index:i];
            }];
        }else{
            [self adjustScaleFrame:draper index:i];
        }
        
    }
    
    
    [self managerDraperAppear];
    
    
}

-(void)freshFront{
    NSArray *fontThree = [self.draperViewArray subarrayWithRange:NSMakeRange(0, SHOW_COUNT)];
    //NSArray *images = self.freshModelsInRange(_draperIndex,SHOW_COUNT);
    NSArray *images = [self data:self.dataArray itemIndex:_draperIndex shou:SHOW_COUNT];
    [self styleDraper:fontThree withImages:images];
}



-(void)managerDraperAppear{
    
    NSArray *prefixs = [self.draperViewArray subarrayWithRange:NSMakeRange(0, SHOW_COUNT*2)];
    for (int i = 0; i<prefixs.count; i++) {
        Draper *draper = [prefixs objectAtIndex:i];
        draper.hidden =  i<SHOW_COUNT? NO:YES;
    }
    
}
-(NSArray *)data:(NSArray *)datas itemIndex:(NSInteger)index  shou:(NSInteger)showCount{
    
    if (index<=datas.count-showCount) {
        return [datas subarrayWithRange:NSMakeRange(index, showCount)];
    }else{
        NSInteger l = datas.count- index;
        NSInteger r = showCount - l;
        
        NSMutableArray *temp = [NSMutableArray array];
        for (NSInteger i = index; i < datas.count;i++) {
            [temp addObject:datas[i]];
        }
        for (NSInteger i =0; i<r; i++) {
            [temp addObject:datas[i]];
        }
        return (NSArray *)temp;
    }
}


@end