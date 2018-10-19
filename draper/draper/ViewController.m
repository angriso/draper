//
//  ViewController.m
//  draper
//
//  Created by niang on 2018/10/19.
//  Copyright © 2018年 Jeby. All rights reserved.
//

#import "ViewController.h"
#import "DraperWall.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:@[@""]];
        
        NSDictionary *dic = [self loadData];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSArray *items = dic[@"items"];
            for (NSDictionary *itm in items) {
                NSString *pic_url = itm[@"pic_url"];
                [array addObject:pic_url];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            DraperWall *wall = [[DraperWall alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:wall];
            [wall addFreshData:array];
        });
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSDictionary *)loadData{
    static NSDictionary *data = nil;
    if (!data) {
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"meinv" ofType:@"json"]];
        id obj = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            data = obj;
        }
    }
    return data;;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
