//
//  mainVC.m
//  PhotoBrowser
//
//  Created by 王修帅 on 2018/1/18.
//  Copyright © 2018年 王修帅. All rights reserved.
//

#import "mainVC.h"
#import "PBView.h"

@interface mainVC ()

@end

@implementation mainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"查看图片详情"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    UIButton * imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgBtn setFrame:CGRectMake(100, 100, 250, 50)];
    [imgBtn setTitle:@"查看图片" forState:UIControlStateNormal];
    [imgBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [imgBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [imgBtn setBackgroundColor:[UIColor magentaColor]];
    [imgBtn addTarget:self action:@selector(imgBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imgBtn];
}
-(void)imgBtnDidPress:(UIButton *)sender
{
//    NSArray * imgUrlArr = @[
//                            @"http://chuantu.biz/t6/209/1516262253x-1404817814.png",
//                            @"http://chuantu.biz/t6/209/1516262344x-1404817814.png",
//                            @"http://chuantu.biz/t6/209/1516262392x-1404817814.jpg",
//                            @"http://chuantu.biz/t6/209/1516262443x-1404817790.jpg",
//                            @"http://chuantu.biz/t6/209/1516262484x-1404817790.jpg",
//                            @"http://chuantu.biz/t6/209/1516262522x-1404817790.jpg"
//                            ];
    
    NSArray * imgUrlArr = @[
                            [UIImage imageNamed:@"1769276-caf9974cb89d877a"],
                            [UIImage imageNamed:@"1769276-caf9974cb89d877a"],
                            [UIImage imageNamed:@"1769276-caf9974cb89d877a"],
                            [UIImage imageNamed:@"1769276-caf9974cb89d877a"],
                            [UIImage imageNamed:@"1769276-caf9974cb89d877a"]
                            ];
    
    
    PBView * pbView = [[PBView alloc] init];
    
    pbView.imgUrlArr = imgUrlArr;
    
    pbView.currentIndex = 3;
        
    [pbView show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
