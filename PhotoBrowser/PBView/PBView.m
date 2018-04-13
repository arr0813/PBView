//
//  PBView.m
//  PhotoBrowser
//
//  Created by 王修帅 on 2018/1/18.
//  Copyright © 2018年 王修帅. All rights reserved.
//

#import "PBView.h"
#import "PictureDetailsCell.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>


//屏幕宽高
#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height

//用来适配iPhoneX
#define NaviHigh ([UIScreen mainScreen].bounds.size.height==812.0?88.0:64.0)
#define TabBarHigh ([UIScreen mainScreen].bounds.size.height==812.0?83.0:49.0)

@interface PBView ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate>

/** collectionView */
@property(nonatomic, strong) UICollectionView *collectionView;

/** 选择按钮 */
@property(nonatomic, strong) UIButton *selectedBtn;

/** 页码 */
@property(nonatomic, strong) UILabel *pageLabel;

/** cell */
@property(nonatomic, strong) PictureDetailsCell *cell;

/** 放大的ScrollView */
@property(nonatomic, strong) UIScrollView *bigScrollView;

/** 记录当前的图片 */
@property(nonatomic, strong) UIImage *currentImage;

/** collectionview偏移量 */
@property(nonatomic, assign) NSInteger page;

@end

static NSString *ID = @"PictureDetailsCell";

@implementation PBView

-(instancetype )init
{
    if (self = [super init])
    {
        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        
        [self setBackgroundColor:[UIColor blackColor]];
        
        [self setAlpha:0];
    }
    return self;
}
#pragma mark - 显示 -
-(void)show
{
    [[[UIApplication sharedApplication]keyWindow]addSubview:self];
    
    //animated为YES可以滚动到指定位置，为NO不能滚动，把代码放在主线程就可以了
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.collectionView setContentOffset:CGPointMake (self.currentIndex * SCREENWIDTH, 0) animated:NO];
                   });
    //点击图片时显示大图时，点击速度快的话会多次触发tap手势，点击手势触发后添加个backTmpView到keyWindow，等动画完毕再移除
    UIView * backTmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    
    [backTmpView setBackgroundColor:[UIColor clearColor]];
    
    [[UIApplication sharedApplication].keyWindow addSubview:backTmpView];
    
    //创建imageview，出现时的动画效果都加在imageview上，动画效果完毕移除imageview，显示collectionView
    UIImageView * animatedImg = [[UIImageView alloc] initWithFrame:CGRectMake(-SCREENWIDTH*2,-SCREENHEIGHT*2,SCREENWIDTH*5,SCREENHEIGHT*5)];
    [animatedImg setBackgroundColor:[UIColor blackColor]];
    if ([self.imgUrlArr[self.currentIndex] isKindOfClass:[NSString class]])
    {
        [animatedImg sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArr[self.currentIndex]]];
    }
    else
    {
        [animatedImg setImage:self.imgUrlArr[self.currentIndex]];
    }
    [animatedImg setContentMode:UIViewContentModeScaleAspectFit];
    [animatedImg setClipsToBounds:YES];
    [animatedImg setAlpha:0];
    [[UIApplication sharedApplication].keyWindow addSubview:animatedImg];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.selectedBtn];
    
    [self.pageLabel setText:[NSString stringWithFormat:@"%zd/%zd", self.currentIndex + 1, self.imgUrlArr.count]];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [animatedImg setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        
        [animatedImg setAlpha:1];
        
    } completion:^(BOOL finished) {
        
        [self setAlpha:1];
        
        [self.collectionView setAlpha:1];
        
        [self.selectedBtn setAlpha:1];
        
        [animatedImg removeFromSuperview];
        
        [backTmpView removeFromSuperview];
    }];
}
#pragma mark - 懒加载
-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    self.page = _currentIndex;
}
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(SCREENWIDTH, SCREENHEIGHT);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.layer.masksToBounds = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = YES;
        _collectionView.alpha = 0;
        [_collectionView registerClass:[PictureDetailsCell class] forCellWithReuseIdentifier:ID];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}
- (UIButton *)selectedBtn
{
    if (!_selectedBtn)
    {
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.frame = CGRectMake(SCREENWIDTH - 50, (NaviHigh == 64.0)?152.0 :(44 + 15), 40, 20);
        _selectedBtn.backgroundColor = [UIColor clearColor];
        [_selectedBtn setTitle:@"···" forState:UIControlStateNormal];
        [_selectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectedBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
        _selectedBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _selectedBtn.layer.masksToBounds = YES ;
        _selectedBtn.layer.cornerRadius = 10;
        _selectedBtn.layer.borderWidth = 1;
        _selectedBtn.alpha = 0;
        _selectedBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
        [_selectedBtn addTarget:self action:@selector(clickSelectedBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedBtn;
}
- (UILabel *)pageLabel
{
    if (!_pageLabel)
    {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 30, SCREENWIDTH, 20)];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.font = [UIFont systemFontOfSize:18.0];
        _pageLabel.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_pageLabel];
    }
    return _pageLabel;
}
#pragma mark - 右上角按钮保存或者分享 -
/** 由于collectionview有点小问题，导致通过按钮来保存或者分享图片时，不能获取正确的图片，可以通过scrollViewDidEndDecelerating来获取当前为第几张图片，重新下载来保存或分享 */
- (void)clickSelectedBtn{
    
    UIImageView * currentImageView = [[UIImageView alloc]init];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //取消
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                      {
                      }]];
    
    //分享
    [alert addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                      {
                          NSLog(@"分享");
                      }]];
    
    //保存相册
    [alert addAction:[UIAlertAction actionWithTitle:@"保存至手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:@"正在保存"];
        
        [currentImageView sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArr[self.page]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [SVProgressHUD showWithStatus:@"正在保存"];
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        
    }]];
    //找到顶部视图控制器
    UIWindow * alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    alertWindow.rootViewController = [[UIViewController alloc] init];
    
    alertWindow.windowLevel = UIWindowLevelAlert + 1;
    
    [alertWindow makeKeyAndVisible];
    
    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 长按保存（分享，保存）
- (void)clickSelectedBtnWithImage:(UIImage *)image
{
    UIImageView  * currentImageView = [[UIImageView alloc]init];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //取消
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                      {
                      }]];
    
    //分享
    [alert addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                      {
                          NSLog(@"分享");
                      }]];
    
    //保存相册
    [alert addAction:[UIAlertAction actionWithTitle:@"保存至手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:@"正在保存"];
        
        [currentImageView sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArr[self.page]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [SVProgressHUD showWithStatus:@"正在保存"];
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        
    }]];
    //找到顶部视图控制器
    UIWindow * alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    alertWindow.rootViewController = [[UIViewController alloc] init];
    
    alertWindow.windowLevel = UIWindowLevelAlert + 1;
    
    [alertWindow makeKeyAndVisible];
    
    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}
//保存到手机的方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"%@", error);
    
    if (error)
    {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"保存成功" ];
        //延时
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
        });
    }
}
#pragma mark - CollectionView代理方法

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imgUrlArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    //因为一页显示一张图片，只需通过indexPath.row来显示就行
    if ([self.imgUrlArr[indexPath.row] isKindOfClass:[NSString class]])
    {
        [self.cell setImageWithUrl:self.imgUrlArr[indexPath.row]];
    }
    else
    {
        [self.cell setImageWithImg:self.imgUrlArr[indexPath.row]];
    }
    //单双击的Block回调
    __weak typeof(self.cell) weakcell = self.cell;
    
    __weak typeof(self) weakself = self;
    
    self.cell.longPressBlock = ^(UILongPressGestureRecognizer * longPress)
    {
        if (longPress.state == UIGestureRecognizerStateBegan)
        {
            UIImageView * imageView = (UIImageView *)longPress.view;
            
            [weakself clickSelectedBtnWithImage:imageView.image];
        }
    };
    //单击退出
    self.cell.tapBlock = ^(UITapGestureRecognizer *tapGR)
    {
        [weakself.selectedBtn setAlpha:0];
        
        if (tapGR.numberOfTapsRequired == 1)
        {
            //消失动画
            [UIView animateWithDuration:0.5 animations:^{
                
                [weakself setAlpha:0];
                
                [weakself.collectionView setTransform:CGAffineTransformScale(weakself.collectionView.transform, 5, 5)];
                
                [weakself.collectionView setAlpha:0];
            }completion:^(BOOL finished)
             {
                 [weakself removeFromSuperview];
                 
                 [weakself.selectedBtn removeFromSuperview];
                 
                 [weakself.pageLabel removeFromSuperview];
             }];
        }
        //双击放大缩小
        else if (tapGR.numberOfTapsRequired == 2)
        {
            if (weakcell.scrollView.zoomScale == 1.0)
            {
                [UIView animateWithDuration:0.5 animations:^
                 {
                     weakcell.scrollView.zoomScale = 4.0;
                 }];
                weakself.bigScrollView = weakcell.scrollView ;
            }
            else{
                
                [UIView animateWithDuration:0.5 animations:^
                 {
                     weakcell.scrollView.zoomScale = 1.0;
                 }];
                weakself.bigScrollView = nil ;
            }
        }
    };
    return self.cell;
}
//通过collectionView来设置页码时，会出现页码和实际不对应（点击进入collectionview查看大图，第一次滑动时cellForItemAtIndexPath会执行两次），由于collectionView继承于scrollView，可以通过scrollView的方法来设置页码
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (self.bigScrollView)
    {
        self.bigScrollView.zoomScale = 1 ;
        
        self.bigScrollView = nil ;
    }
    //根据当前偏移量获取是第几张图片，并根据URL重新下载图片来保存或分享
    self.page = scrollView.contentOffset.x / SCREENWIDTH ;
    
    //设置页码Label
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.page + 1 , self.imgUrlArr.count];
}
@end


////
////  PBView.m
////  PhotoBrowser
////
////  Created by 王修帅 on 2018/1/18.
////  Copyright © 2018年 王修帅. All rights reserved.
////
//
//#import "PBView.h"
//#import "PictureDetailsCell.h"
//#import <SVProgressHUD.h>
//#import <UIImageView+WebCache.h>
//
//
////屏幕宽高
//#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
//#define SCREENHEIGHT [[UIScreen mainScreen] bounds].size.height
//
//@interface PBView ()<UICollectionViewDelegate,
//                     UICollectionViewDataSource,
//                     UICollectionViewDelegateFlowLayout,
//                     UIScrollViewDelegate>
//
///** collectionView */
//@property(nonatomic, strong) UICollectionView *collectionView;
//
///** 选择按钮 */
//@property(nonatomic, strong) UIButton *selectedBtn;
//
///** 页码 */
//@property(nonatomic, strong) UILabel *pageLabel;
//
///** cell */
//@property(nonatomic, strong) PictureDetailsCell *cell;
//
///** 放大的ScrollView */
//@property(nonatomic, strong) UIScrollView *bigScrollView;
//
///** 记录当前的图片 */
//@property(nonatomic, strong) UIImage *currentImage;
//
///** collectionview偏移量 */
//@property(nonatomic, assign) NSInteger page;
//
//@end
//
//static NSString *ID = @"PictureDetailsCell";
//
//@implementation PBView
//
//-(instancetype )init
//{
//    if (self = [super init])
//    {
//        [self setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
//
//        [self setBackgroundColor:[UIColor blackColor]];
//
//        [self setAlpha:0];
//    }
//    return self;
//}
//#pragma mark - 显示 -
//-(void)show
//{
//    [[[UIApplication sharedApplication]keyWindow]addSubview:self];
//
//    //animated为YES可以滚动到指定位置，为NO不能滚动，把代码放在主线程就可以了
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
//        [self.collectionView setContentOffset:CGPointMake (self.currentIndex * SCREENWIDTH, 0) animated:NO];
//    });
//    //点击图片时显示大图时，点击速度快的话会多次触发tap手势，点击手势触发后添加个backTmpView到keyWindow，等动画完毕再移除
//    UIView * backTmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
//
//    [backTmpView setBackgroundColor:[UIColor clearColor]];
//
//    [[UIApplication sharedApplication].keyWindow addSubview:backTmpView];
//
//    //创建imageview，出现时的动画效果都加在imageview上，动画效果完毕移除imageview，显示collectionView
//    UIImageView * animatedImg = [[UIImageView alloc] initWithFrame:CGRectMake(-SCREENWIDTH*2,-SCREENHEIGHT*2,SCREENWIDTH*5,SCREENHEIGHT*5)];
//    [animatedImg setBackgroundColor:[UIColor blackColor]];
//    if ([self.imgUrlArr[self.currentIndex] isKindOfClass:[NSString class]])
//    {
//        [animatedImg sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArr[self.currentIndex]]];
//    }
//    else
//    {
//        [animatedImg setImage:self.imgUrlArr[self.currentIndex]];
//    }
//    [animatedImg setContentMode:UIViewContentModeScaleAspectFit];
//    [animatedImg setClipsToBounds:YES];
//    [animatedImg setAlpha:0];
//    [[UIApplication sharedApplication].keyWindow addSubview:animatedImg];
//
//    [[UIApplication sharedApplication].keyWindow addSubview:self.selectedBtn];
//
//    [self.pageLabel setText:[NSString stringWithFormat:@"%zd/%zd", self.currentIndex + 1, self.imgUrlArr.count]];
//
//    [UIView animateWithDuration:0.5 animations:^{
//
//        [animatedImg setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
//
//        [animatedImg setAlpha:1];
//
//    } completion:^(BOOL finished) {
//
//        [self setAlpha:1];
//
//        [self.collectionView setAlpha:1];
//
//        [animatedImg removeFromSuperview];
//
//        [backTmpView removeFromSuperview];
//    }];
//}
//#pragma mark - 懒加载
//-(void)setCurrentIndex:(NSInteger)currentIndex
//{
//    _currentIndex = currentIndex;
//
//    self.page = _currentIndex;
//}
//- (UICollectionView *)collectionView
//{
//    if (!_collectionView)
//    {
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        layout.itemSize = CGSizeMake(SCREENWIDTH, SCREENHEIGHT);
//        layout.minimumLineSpacing = 0;
//        layout.minimumInteritemSpacing = 0;
//
//        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) collectionViewLayout:layout];
//        _collectionView.showsVerticalScrollIndicator = NO;
//        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.backgroundColor = [UIColor blackColor];
//        _collectionView.layer.masksToBounds = YES;
//        _collectionView.pagingEnabled = YES;
//        _collectionView.dataSource = self;
//        _collectionView.delegate = self;
//        _collectionView.bounces = YES;
//        _collectionView.alpha = 0;
//        [_collectionView registerClass:[PictureDetailsCell class] forCellWithReuseIdentifier:ID];
//        [self addSubview:_collectionView];
//    }
//    return _collectionView;
//}
//- (UIButton *)selectedBtn
//{
//    if (!_selectedBtn)
//    {
//        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _selectedBtn.frame = CGRectMake(SCREENWIDTH - 50, 15, 40, 20);
//        _selectedBtn.backgroundColor = [UIColor clearColor];
//        [_selectedBtn setTitle:@"···" forState:UIControlStateNormal];
//        [_selectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        _selectedBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
//        _selectedBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//        _selectedBtn.layer.masksToBounds = YES ;
//        _selectedBtn.layer.cornerRadius = 10;
//        _selectedBtn.layer.borderWidth = 1;
//        _selectedBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
//        [_selectedBtn addTarget:self action:@selector(clickSelectedBtn) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _selectedBtn;
//}
//- (UILabel *)pageLabel
//{
//    if (!_pageLabel)
//    {
//        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 30, SCREENWIDTH, 20)];
//        _pageLabel.textColor = [UIColor whiteColor];
//        _pageLabel.textAlignment = NSTextAlignmentCenter;
//        _pageLabel.font = [UIFont systemFontOfSize:18.0];
//        _pageLabel.backgroundColor = [UIColor clearColor];
//        [[UIApplication sharedApplication].keyWindow addSubview:_pageLabel];
//    }
//    return _pageLabel;
//}
//#pragma mark - 右上角按钮保存或者分享 -
///** 由于collectionview有点小问题，导致通过按钮来保存或者分享图片时，不能获取正确的图片，可以通过scrollViewDidEndDecelerating来获取当前为第几张图片，重新下载来保存或分享 */
//- (void)clickSelectedBtn{
//
//    UIImageView * currentImageView = [[UIImageView alloc]init];
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    //取消
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
//    {
//    }]];
//
//    //分享
//    [alert addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
//    {
//        NSLog(@"分享");
//    }]];
//
//    //保存相册
//    [alert addAction:[UIAlertAction actionWithTitle:@"保存至手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        [SVProgressHUD showWithStatus:@"正在保存"];
//
//        [currentImageView sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArr[self.page]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//            [SVProgressHUD showWithStatus:@"正在保存"];
//
//            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        }];
//
//    }]];
//    //找到顶部视图控制器
//    UIWindow * alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//
//    alertWindow.rootViewController = [[UIViewController alloc] init];
//
//    alertWindow.windowLevel = UIWindowLevelAlert + 1;
//
//    [alertWindow makeKeyAndVisible];
//
//    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//}
//#pragma mark - 长按保存（分享，保存）
//- (void)clickSelectedBtnWithImage:(UIImage *)image
//{
//    UIImageView  * currentImageView = [[UIImageView alloc]init];
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//
//    //取消
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
//                      {
//                      }]];
//
//    //分享
//    [alert addAction:[UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
//                      {
//                          NSLog(@"分享");
//                      }]];
//
//    //保存相册
//    [alert addAction:[UIAlertAction actionWithTitle:@"保存至手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        [SVProgressHUD showWithStatus:@"正在保存"];
//
//        [currentImageView sd_setImageWithURL:[NSURL URLWithString:self.imgUrlArr[self.page]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//            [SVProgressHUD showWithStatus:@"正在保存"];
//
//            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        }];
//
//    }]];
//    //找到顶部视图控制器
//    UIWindow * alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//
//    alertWindow.rootViewController = [[UIViewController alloc] init];
//
//    alertWindow.windowLevel = UIWindowLevelAlert + 1;
//
//    [alertWindow makeKeyAndVisible];
//
//    [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//}
////保存到手机的方法
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    NSLog(@"%@", error);
//
//    if (error)
//    {
//        [SVProgressHUD showErrorWithStatus:@"保存失败"];
//    }
//    else
//    {
//        [SVProgressHUD showSuccessWithStatus:@"保存成功" ];
//        //延时
//        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
//
//        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//
//            [SVProgressHUD dismiss];
//        });
//    }
//}
//#pragma mark - CollectionView代理方法
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.imgUrlArr.count;
//}
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    self.cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
//
//    //因为一页显示一张图片，只需通过indexPath.row来显示就行
//    if ([self.imgUrlArr[indexPath.row] isKindOfClass:[NSString class]])
//    {
//        [self.cell setImageWithUrl:self.imgUrlArr[indexPath.row]];
//    }
//    else
//    {
//        [self.cell setImageWithImg:self.imgUrlArr[indexPath.row]];
//    }
//    //单双击的Block回调
//    __weak typeof(self.cell) weakcell = self.cell;
//
//    __weak typeof(self) weakself = self;
//
//    self.cell.longPressBlock = ^(UILongPressGestureRecognizer * longPress)
//    {
//        if (longPress.state == UIGestureRecognizerStateBegan)
//        {
//            UIImageView * imageView = (UIImageView *)longPress.view;
//
//            [weakself clickSelectedBtnWithImage:imageView.image];
//        }
//    };
//    //单击退出
//    self.cell.tapBlock = ^(UITapGestureRecognizer *tapGR)
//    {
//        if (tapGR.numberOfTapsRequired == 1)
//        {
//            //消失动画
//            [UIView animateWithDuration:0.5 animations:^{
//
//                [weakself setAlpha:0];
//
//                [weakself.collectionView setTransform:CGAffineTransformScale(weakself.collectionView.transform, 5, 5)];
//
//                [weakself.collectionView setAlpha:0];
//            }completion:^(BOOL finished)
//             {
//                 [weakself removeFromSuperview];
//
//                 [weakself.selectedBtn removeFromSuperview];
//
//                 [weakself.pageLabel removeFromSuperview];
//             }];
//        }
//        //双击放大缩小
//        else if (tapGR.numberOfTapsRequired == 2)
//        {
//            if (weakcell.scrollView.zoomScale == 1.0)
//            {
//                [UIView animateWithDuration:0.5 animations:^
//                {
//                    weakcell.scrollView.zoomScale = 4.0;
//                }];
//                weakself.bigScrollView = weakcell.scrollView ;
//            }
//            else{
//
//                [UIView animateWithDuration:0.5 animations:^
//                {
//                    weakcell.scrollView.zoomScale = 1.0;
//                }];
//                weakself.bigScrollView = nil ;
//            }
//        }
//    };
//    return self.cell;
//}
////通过collectionView来设置页码时，会出现页码和实际不对应（点击进入collectionview查看大图，第一次滑动时cellForItemAtIndexPath会执行两次），由于collectionView继承于scrollView，可以通过scrollView的方法来设置页码
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//
//    if (self.bigScrollView)
//    {
//        self.bigScrollView.zoomScale = 1 ;
//
//        self.bigScrollView = nil ;
//    }
//    //根据当前偏移量获取是第几张图片，并根据URL重新下载图片来保存或分享
//    self.page = scrollView.contentOffset.x / SCREENWIDTH ;
//
//    //设置页码Label
//    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.page + 1 , self.imgUrlArr.count];
//}
//@end
