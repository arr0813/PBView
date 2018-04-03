//
//  PictureDetailsCell.h
//  BGH
//
//  Created by Sunny on 16/11/30.
//  Copyright © 2016年 Rongtong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^tapBlock)(UITapGestureRecognizer *);

typedef void (^longPressBlock)(UILongPressGestureRecognizer *);

@interface PictureDetailsCell : UICollectionViewCell<UIScrollViewDelegate>

/** scrollView */
@property(nonatomic, strong) UIScrollView *scrollView;

/** imageView */
@property(nonatomic, strong) UIImageView *imageView;

/** 点击图片的Block */
@property(nonatomic, copy) tapBlock tapBlock;

/** 图片长按手势的Block*/
@property(nonatomic, copy) longPressBlock longPressBlock;

//设置图片
- (void)setImageWithUrl:(NSString *)url;
- (void)setImageWithImg:(UIImage  *)img;

//限制图片放大后的滑动范围
- (void)setImageOfImageView:(UIImage *)image;

@end
