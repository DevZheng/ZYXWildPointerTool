//
//  ViewController.m
//  WildPointer
//
//  Created by Zheng,Yuxin on 2018/12/20.
//  Copyright © 2018 Zheng,Yuxin. All rights reserved.
//

#import "ViewController.h"
#import "ZYXWildPointer/ZYXWildPointerTool.h"

@interface Spark : NSObject

@property (nonatomic, strong) NSData *data;

@end

@implementation Spark


@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    begin_check_wild_pointer();

    // Do any additional setup after loading the view, typically from a nib.
    
    UIView* testObj = [[UIView alloc] init];
    [testObj release];
    for (int i = 0; i < 10; i++) {
        UIView* testView=[[UIView alloc] initWithFrame:CGRectMake(0,200,CGRectGetWidth(self.view.bounds), 60)];
        [self.view addSubview:testView];
    }
    [testObj setNeedsLayout];
}


@end
