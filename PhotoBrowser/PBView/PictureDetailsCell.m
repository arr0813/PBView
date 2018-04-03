//
//  PictureDetailsCell.m
//  BGH
//
//  Created by Sunny on 16/11/30.
//  Copyright © 2016年 Rongtong. All rights reserved.
//

#import "PictureDetailsCell.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDWebImageManager.h>

//屏幕宽高
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height

@interface PictureDetailsCell()<UIScrollViewDelegate>

/** 单机 */
@property(nonatomic, strong) UITapGestureRecognizer *tapGR1;
/** 双击 */
@property(nonatomic, strong) UITapGestureRecognizer *tapGR2;
/** 长按*/
@property(nonatomic, strong) UILongPressGestureRecognizer * longPress;

@property(nonatomic, strong)UIImage * downLoadImaga;
@end

@implementation PictureDetailsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.bouncesZoom = YES;
        self.scrollView.delegate = self;
        self.scrollView.maximumZoomScale = 4.0;
        self.scrollView.minimumZoomScale = 1.0;
        [self.contentView addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:self.imageView];
        
        //添加单击手势
        self.tapGR1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnThe:)];
        [self.tapGR1 setNumberOfTapsRequired:1];//设置单击次数
        [self addGestureRecognizer:self.tapGR1];
        
        //添加双击手势
        self.tapGR2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClickOnThe:)];
        [self.tapGR2 setNumberOfTapsRequired:2];//设置单击次数
        [self.tapGR2 setNumberOfTouchesRequired:1];//设置手指的数量
        [self.imageView addGestureRecognizer:self.tapGR2];
        
        //如果不加下面的话，当单指双击时，会先调用单指单击中的处理，再调用单指双击中的处理
        [self.tapGR1 requireGestureRecognizerToFail:self.tapGR2];
        
        //长按保存到相册的手势
        self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressDidPress:)];
        [self.longPress setMinimumPressDuration:1];//最小长按时间
        [self.imageView addGestureRecognizer:self.longPress ];
    }
    
    return self;
}
#pragma mark - 显示图片 -> 传进来URL时 -
- (void)setImageWithUrl:(NSString *)url
{
    //获取缓存中之前请求到的图片
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@",url]];
    
    if (!cachedImage)
    {
        [SVProgressHUD show];
    }
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon_noImg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        [SVProgressHUD dismiss];
        
        [self setImageOfImageView:image];
    }];
}
- (void)setImageWithImg:(UIImage *)img
{
    [self.imageView setImage:img];
    
    [self setImageOfImageView:img];
}
- (void)setImageOfImageView:(UIImage *)image    
{
    if (image)
    {
        //得到缩放比例
        float sclX = self.frame.size.width / image.size.width;
        float sclY = self.frame.size.height / image.size.height;
        
        CGFloat imageHeight = image.size.height * sclX;
        CGFloat imageWidth = self.frame.size.width;
        
        if (sclX > sclY)
        {
            imageWidth = image.size.width * sclY;
            imageHeight = self.frame.size.height;
        }
        
        //这里只能用frame不能用约束，否则当缩放时约束会重新调整位置，没有居中
        self.imageView.frame = (CGRect){self.frame.size.width / 2 - imageWidth / 2, self.frame.size.height / 2 - imageHeight / 2, imageWidth, imageHeight};
    }
}

#pragma mark - 单击
- (void)clickOnThe:(UITapGestureRecognizer *)tapGR
{
    self.tapBlock(tapGR);
}

#pragma mark - 双击
- (void)doubleClickOnThe:(UITapGestureRecognizer *)tapGR
{
    self.tapBlock(tapGR);
}

#pragma mark - 长按 -
-(void)longPressDidPress:(UILongPressGestureRecognizer *)longPress{
    
    self.longPressBlock(longPress);
}
#pragma mark - <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = self.imageView.frame;
    
    CGSize contentSize = scrollView.contentSize;
    
    CGPoint centerPoint = CGPointMake(contentSize.width / 2, contentSize.height / 2);
    
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width / 2;
    }    
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height / 2;
    }
    self.imageView.center = centerPoint;
}


@end
