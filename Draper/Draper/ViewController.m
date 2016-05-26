//
//  ViewController.m
//  Draper
//
//  Created by jerrysun on 16/5/24.
//  Copyright © 2016年 hydee. All rights reserved.
//

#import "ViewController.h"

#import "Draper.h"
#import "DraperBox.h"


@interface ViewController ()
@property (nonatomic ,strong) NSMutableArray *dataArray;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    

    self.dataArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<21; i++) {
       [self.dataArray addObject:[NSString stringWithFormat:@"%ld.%@",i,@"jpg"]];
    }
    
    DraperBox *box = [[DraperBox alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [box configureWithData:self.dataArray];
    
    box.didTapDraper = ^(NSInteger index){
        NSLog(@"%ld",(long)index);
    };
    [self.view addSubview:box];
    
}









//    __weak typeof(self) weakSelf = self;
//
//    box.freshModelsInRange = ^(NSInteger itemIndex,NSInteger showCount){
//
//        if (itemIndex == weakSelf.dataArray.count-2) {
//            return @[weakSelf.dataArray[weakSelf.dataArray.count-2],
//                     weakSelf.dataArray[weakSelf.dataArray.count-1],
//                     weakSelf.dataArray[0]];
//        }else if(itemIndex == weakSelf.dataArray.count-1) {
//            return @[weakSelf.dataArray[weakSelf.dataArray.count-1],
//                     weakSelf.dataArray[0],
//                     weakSelf.dataArray[1]];
//        }else{
//            return [weakSelf.dataArray subarrayWithRange:NSMakeRange(itemIndex, showCount)];
//        }
//    };

@end