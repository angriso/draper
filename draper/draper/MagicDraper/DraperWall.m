//
//  AmazingWall.m
//  Camera
//
//  Created by jerrysun on 2016/10/26.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import "DraperWall.h"
#import "DraperCard.h"
#import "UIImageView+WebCache.h"
@interface  DraperWall ()<DraperDelegate>
@property (nonatomic ,strong) UIView *wallpaper;
@property (nonatomic ,strong) UIImageView *blurBackgroundImageView;
@property (nonatomic ,strong) NSMutableArray *dataArrys;
@property (nonatomic ,strong) NSMutableArray *availableCards;
@property (nonatomic ,strong) NSMutableArray *normalCards;
@property (nonatomic ,assign) NSInteger curentPage;
@property (nonatomic ,assign) NSInteger loadCount;
@property (nonatomic ,assign) NSInteger prestrainCount;
@property (nonatomic ,assign) BOOL hadPrestrain;
@property (nonatomic ,assign) CGRect originCardRect;
@end

@implementation DraperWall
- (NSMutableArray *)availableCards
{
    if (!_availableCards) {
        _availableCards = [NSMutableArray array];
    }
    return _availableCards;
}
- (NSMutableArray *)normalCards
{
    if (!_normalCards) {
        _normalCards = [NSMutableArray array];
    }
    return _normalCards;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    _prestrainCount = 1;
    
    _normalShowCount = 3;
    
    CGSize size = CGSizeMake(260, 340);
    _originCardRect = CGRectMake((self.bounds.size.width-size.width)/2,(self.bounds.size.height-size.height)/2,size.width ,size.height);
    
    _blurBackgroundImageView = [UIImageView new];
    _blurBackgroundImageView.frame = self.bounds;
    [self addSubview:_blurBackgroundImageView];
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectView.frame = _blurBackgroundImageView.bounds;
    [_blurBackgroundImageView addSubview:effectView];
    
    _wallpaper = [UIView new];
    _wallpaper.frame = self.bounds;
    _wallpaper.backgroundColor = [UIColor clearColor];
    [self addSubview:_wallpaper];
    
    for (int i = 0; i<20; i++) {
        DraperCard *card = [self newCard];
        [self.availableCards addObject:card];
    }
}
- (DraperCard *)newCard
{
    DraperCard *card = [[DraperCard alloc] initWithFrame:_originCardRect];
    card.delegate = self;
    card.originCenter = CGPointMake(CGRectGetMidX(card.frame), CGRectGetMidY(card.frame));
    card.hidden = YES;
    __weak typeof (self) welf = self;
    [card setRunThrow:^(DraperCard *pd) {
        
        CGRect extendRect = CGRectInset(pd.superview.bounds, -100, -100);
        
        if (CGRectIsEmpty(CGRectIntersection(extendRect, card.frame))||
            CGRectIsNull(CGRectIntersection(extendRect, card.frame))) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [pd performSelector:@selector(resetDraper)
                            onThread:[NSThread mainThread]
                          withObject:nil
                       waitUntilDone:NO];
#pragma clang diagnostic pop
            
            pd.hidden = YES;
            pd.transform = CGAffineTransformIdentity;
            pd.frame = welf.originCardRect;
            [pd removeFromSuperview];
            [welf.availableCards addObject:pd];
            NSLog(@"reset--availbe count:%d",(int)welf.availableCards.count);
        }
    }];
    
    [card addAnimatorsWithReferenceView:_wallpaper];
    
    return card;
}
- (void)addFreshData:(NSArray *)array
{
    self.curentPage = 0;
    self.dataArrys = array.mutableCopy;
    
    [self reloadData];
}
- (void)appendingData:(NSArray *)array
{
    [self.dataArrys addObjectsFromArray:array];
}
- (NSInteger)loadCount{
    
    //预加载建立在数据个数大于 先是个数加与加载过额数
    //加入预期加载所以加载过的个数就等于 normalShowCount + prestrainCount
    
    if (_dataArrys.count >= _normalShowCount+_prestrainCount){
        _loadCount = _normalShowCount+_prestrainCount;
        _hadPrestrain = YES;
    }else {
        _loadCount = _dataArrys.count;
        _hadPrestrain = NO;
    }
    return _loadCount;
}

- (void)reloadData
{
    // 加载把所以试图装入avail

    if (self.normalCards.count>0) {
        [self.availableCards addObjectsFromArray:self.normalCards];
        [self.normalCards removeAllObjects];
    }
    
    // show count
    NSInteger showCount = self.dataArrys.count < self.normalShowCount ? self.dataArrys.count : self.normalShowCount;
    
    if (showCount>self.availableCards.count) return;
    
    // load prestrainCount
    NSInteger loadCount = self.loadCount;
    
    if (loadCount+self.curentPage>self.dataArrys.count-1) {
        self.curentPage=0;
    }
    
    for (int i = (int)_curentPage; i< loadCount; i++) {
        
        id  data = [self.dataArrys objectAtIndex:i];
       
        DraperCard *draper = [self.availableCards objectAtIndex:i];
        
        if (i<=showCount) {//将要显示的加入
            [_wallpaper insertSubview:draper atIndex:0];
        }
        
        [self setData:data forCard:draper];
    }
    
    // split cards
    NSArray *normalPd = [self.availableCards subarrayWithRange:NSMakeRange(0, showCount)];
    [self.normalCards addObjectsFromArray:normalPd];
    [self.availableCards removeObjectsInArray:normalPd];
    
    
    // layout normalCards
    [self layoutNormalCards];
}
- (void)setData:(id)data forCard:(DraperCard *)pendent
{
    
    if ([data isKindOfClass:[NSString class]]) {
        __weak typeof (self) weakSelf = self;
        [pendent.imageView sd_setImageWithURL:[NSURL URLWithString:data]  placeholderImage:[UIImage imageNamed:@"berry.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([pendent isEqual:[weakSelf.normalCards firstObject]]) {
                weakSelf.blurBackgroundImageView.image = image;
            }
        }];
    }
    if ([data isKindOfClass:[UIImage class]]) {
        pendent.imageView.image = data;
    }
    
}
- (void)layoutNormalCards
{
    DraperCard *front = [_normalCards firstObject];
    front.titleLab.text = @(self.curentPage).stringValue;
    _blurBackgroundImageView.image = front.imageView.image;
    
    for (int i = 0; i<self.normalCards.count; i++) {
        
        DraperCard *draper = [self.normalCards objectAtIndex:i];
        draper.hidden = NO;
        draper.userInteractionEnabled = i==0;
        
        if (i != self.normalCards.count-1){
            
            // 原来不能快速滑过的主要原因是AllowUserInteraction
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                [self transformCard:draper at:i];
            } completion:^(BOOL finished) {
                //
            }];
        }else{
            [self transformCard:draper at:i];
        }
        
    }
}
- (void)transformCard:(DraperCard *)draper at:(int)idx
{
    draper.transform = CGAffineTransformIdentity;
    draper.frame = _originCardRect;
    CGFloat scale =  1 - idx*0.05;
    draper.transform =  CGAffineTransformScale(draper.transform, scale, scale);
    draper.frame = CGRectMake(draper.frame.origin.x, _originCardRect.origin.y, draper.frame.size.width, draper.frame.size.height);
    draper.transform = CGAffineTransformTranslate(draper.transform, 0, -5*idx);
    
}
-(void)draperBeginMoveOut:(DraperCard *)card
{
    card.userInteractionEnabled = NO;
    
    if (![card isEqual:[_normalCards firstObject]]) {
        NSLog(@"bug");
    }
    
    if (_availableCards.count < 10) {
        NSLog(@"数量不够赶紧补充");
    }

    NSInteger loadedCount   = self.loadCount; //已经加载过的个数

    // 因为下标从零开始_curentPage + loadedCount就是下一个需要加载
    NSInteger willLoadIndex = _curentPage + loadedCount; //再加上已经加载过的个数就是将要加载的index

    _curentPage += 1;

    if (willLoadIndex>=self.dataArrys.count) {
        
        //循环显示
        willLoadIndex = willLoadIndex - self.dataArrys.count;//将要加载index如果超过数据则重头开始复位加载(差数就是数据个数)
        if (_curentPage > self.dataArrys.count-1) {//最前面的index大于数据，则复位加载(差数等于数据个数)
            _curentPage = 0;
        }
        
    }
    
    NSLog(@"loadIndex---%d",(int)willLoadIndex);
    
    DraperCard *nextNormalCard = [_availableCards firstObject];
    [_wallpaper insertSubview:nextNormalCard atIndex:0];
    
    [_availableCards removeObjectAtIndex:0];
    [_normalCards removeObjectAtIndex:0];
    [_normalCards addObject:nextNormalCard];
    
    DraperCard *loadCard = nextNormalCard;
    if (_hadPrestrain) { //如果进行了预加载则从可用池取对应未加载
        loadCard = [_availableCards objectAtIndex:_prestrainCount-1];
    }
    id data = [self.dataArrys objectAtIndex:willLoadIndex];
    
    [self  setData:data forCard:loadCard];
    
    [self layoutNormalCards];
    
}

- (void)dealloc{
    
    if  (self.normalCards.count>0) {
        [self.availableCards addObjectsFromArray:self.normalCards];
        [self.normalCards removeAllObjects];
    }
    
    for (DraperCard *card in self.availableCards) {
        [card removeAllAnimations];
        //[card removeObserver:self forKeyPath:@"center"];
        //NSLog(@"remove card observer");
    }
    
    NSLog(@"CardWall---Dealloc");
}



@end
