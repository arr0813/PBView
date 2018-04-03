//
//  PBView.h
//  PhotoBrowser
//
//  Created by 王修帅 on 2018/1/18.
//  Copyright © 2018年 王修帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBView : UIView

/** 存放图片信息的数组 */
@property(nonatomic, strong) NSArray * imgUrlArr;

/** 记录是第几张图片 */
@property(nonatomic, assign) NSInteger currentIndex;

-(instancetype )init;

/** 显示方法：传进某个view去，以view为中心开始显示 */
-(void)show;

@end
