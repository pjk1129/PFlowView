//
//  PFlowView.m
//  PFlowView
//
//  Created by JK.Peng on 13-9-12.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PFlowView.h"

static const NSUInteger kTagOffset = 50;
static const NSUInteger kMaxNumberItemsInView = 7;

@interface PFlowView ()<UIScrollViewDelegate>{
    NSMutableSet *_reusablePFlowViewCells;
}

@property (nonatomic, retain) NSMutableSet   *reusablePFlowViewCells;

@property (nonatomic, retain) UIScrollView   *scrollView;
@property (nonatomic, retain) UIView         *moveView;

@property (nonatomic, assign) NSInteger      lastIndexSelected;

@end

@implementation PFlowView
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize borderColor = _borderColor;
@synthesize scrollView = _scrollView;
@synthesize moveView = _moveView;

@synthesize xMarginValue = _xMarginValue;
@synthesize zMarginValue = _zMarginValue;
@synthesize angleValue = _angleValue;
@synthesize alphaValue = _alphaValue;
@synthesize shadowValueX = _shadowValueX;
@synthesize shadowValueY = _shadowValueY;
@synthesize shadowAlpha = _shadowAlpha;

@synthesize currentIndex = _currentIndex;
@synthesize numberTotalItems = _numberTotalItems;

@synthesize reusablePFlowViewCells = _reusablePFlowViewCells;
@synthesize lastIndexSelected = _lastIndexSelected;

- (void)dealloc{
    self.dataSource = nil;
    self.delegate = nil;
    self.borderColor = nil;
    self.scrollView = nil;
    self.moveView = nil;
    self.reusablePFlowViewCells = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.reusablePFlowViewCells = [NSMutableSet set];
        
        [self addSubview:self.moveView];
        [self addSubview:self.scrollView];
        
        self.borderColor = [UIColor orangeColor];
        self.xMarginValue = 10.0f;
        self.zMarginValue = 5.0f;
        self.alphaValue = 1000.0f;
        self.angleValue = 0.3f;
        self.shadowValueX = 2.0f;
        self.shadowValueY = 2.0f;
        self.shadowAlpha = 0.7f;
        self.currentIndex = 0;
        
        //设置子视图透视投影
        CATransform3D sublayerTransform = CATransform3DIdentity; //单位矩阵
        sublayerTransform.m34 = -0.002;
        [self.moveView.layer setSublayerTransform:sublayerTransform];
        [self.scrollView.layer setSublayerTransform:sublayerTransform];
        

    }
    return self;
}

- (void)reloadData
{
    self.currentIndex = 0;
    self.numberTotalItems = [self dataSourceNumberOfItems];
    
    [self loadRequiredItems];
}

- (PFlowViewCell *)cellForItemAtIndex:(NSInteger)index
{
    PFlowViewCell *view = nil;
    for (PFlowViewCell *v in [self.scrollView subviews]){
        
        if (v.tag == index + kTagOffset){
            view = v;
            break;
        }
    }
    
    return view;
}

- (PFlowViewCell *)cellForItemInMoveViewAtIndex:(NSInteger)index
{
    PFlowViewCell *view = nil;
    for (PFlowViewCell *v in [self.moveView subviews]){
        
        if (v.tag == index + kTagOffset){
            view = v;
            break;
        }
    }
    
    return view;
}

#pragma mark - loading/destroying items & reusing cells
- (void)loadRequiredItems
{
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        [(UIView *)obj removeFromSuperview];
    }];
    
    [[self.moveView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop){
        [(UIView *)obj removeFromSuperview];
    }];
    
    //计算预加载起始位置
    NSInteger  startIndex = 0;
    if (self.currentIndex-2>=0) {
        startIndex = self.currentIndex - 2;
    }
    
    NSInteger  endIndex = 0;
    if (self.currentIndex+6<self.numberTotalItems) {
        endIndex = self.currentIndex +6;
    }else{
        endIndex = self.numberTotalItems;
    }
    
    //加载循环
    for(NSInteger i=startIndex; i<endIndex; i++){
        if (i >=0) {
            [self insertObjectAtIndex:i];
        }
    }
    
    [self cleanupUnseenItems];
    
    //设置滚动视图属性
    if(self.numberTotalItems > 1){
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*self.numberTotalItems,
                                                 CGRectGetHeight(self.scrollView.frame));
    }else{
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*self.numberTotalItems+20,
                                                 CGRectGetHeight(self.scrollView.frame));
    }
}

- (void)relayoutItems
{
    float offset_x = self.scrollView.contentOffset.x;
    float width = self.scrollView.frame.size.width; //视图宽度
    float height = self.scrollView.frame.size.height; //高度
    
    self.currentIndex = roundf(offset_x/width); //得到索引
    
    //改变视图角度
    for (PFlowViewCell *pCell in [self.scrollView subviews]) {
        NSInteger  index = pCell.tag - kTagOffset;
        //调整滚动视图图片的角度
        float currOrigin_x = index * width; //当前图片的x坐标
        float angleValue = (offset_x-currOrigin_x)/width - self.angleValue;
        
        //设置偏移极限
        if(angleValue < -self.angleValue){
            angleValue = -self.angleValue;
        }
        
        if(angleValue > self.alphaValue){
            angleValue = self.alphaValue;
        }
        
        pCell.layer.transform = CATransform3DMakeRotation(angleValue, 0, 1, 0); //改变角度
                
        if(currOrigin_x - offset_x>0){
            if(index != 0){
                pCell.hidden = YES;
            }
        }else{
            pCell.hidden = NO;
        }
  
        
        //调整弹压视图图片的角度
        float range_x = (currOrigin_x-offset_x)/self.xMarginValue;
        PFlowViewCell  *moveCell = (PFlowViewCell  *)[self.moveView viewWithTag:pCell.tag];
        moveCell.frame = CGRectMake(range_x, 0, width, height);
                
        // 如果超过当前滑动视图便隐藏
        if(range_x <= 0){
            moveCell.hidden = YES;
        }else{
            if(index != 0){
                moveCell.hidden = NO;
            }else{
                moveCell.hidden = YES;
            }
        }
        
        //调整弹压视图的z值
        float range_z = (offset_x-currOrigin_x)/self.zMarginValue;
        moveCell.layer.zPosition = range_z;
        //调整弹压视图的透明度
        float alpha = 1.f - (currOrigin_x-offset_x)/self.alphaValue;
        moveCell.alpha = alpha;
    }
}

- (void)cleanupUnseenItems
{
    for (NSInteger i=0; i<self.currentIndex-2; i++) {
        [self removeObjectAtIndex:i];
    }
    
    for (NSInteger i=self.currentIndex+5; i<self.numberTotalItems; i++) {
        [self removeObjectAtIndex:i];
    }
}

- (void)queueReusableCell:(PFlowViewCell *)cell
{
    if (cell) {
        [cell prepareForReuse];
        [self.reusablePFlowViewCells addObject:cell];
        [cell removeFromSuperview];
    }
}

- (PFlowViewCell *)dequeueReusableCell
{
    PFlowViewCell *cell = [self.reusablePFlowViewCells anyObject];
    
    if (cell){
        [self.reusablePFlowViewCells removeObject:cell];
    }
    
    return cell;
}

#pragma mark - insert/remove object at index
- (void)insertObjectAtIndex:(NSInteger)index
{
    PFlowViewCell  *cell = [self cellForItemAtIndex:index];
    if (!cell) {
        CGSize viewSize = self.frame.size;
        float width = viewSize.width; //图宽
        
        //加载滚动视图数据
        CGPoint point = CGPointMake(index*width, 0); //坐标
        PFlowViewCell  *cell = [self.dataSource pFlowView:self cellForItemAtIndex:index];
        cell.tag = index+kTagOffset;
        cell.frame = CGRectMake(point.x, point.y, viewSize.width, viewSize.height);
        cell.layer.transform = CATransform3DMakeRotation(self.angleValue, 0, -1, 0);//设置角度
        if (index!=self.currentIndex) {
            cell.hidden = YES;
        }else{
            cell.hidden = NO;
        }
        
        //设置图片的阴影
        UIBezierPath* shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds];
        cell.layer.shadowPath = shadowPath.CGPath;
        cell.layer.shadowOffset = CGSizeMake(self.shadowValueX, self.shadowValueY);
        cell.layer.shadowOpacity = self.shadowAlpha;
        //设置边框
        if(self.borderColor){
            cell.layer.borderColor = self.borderColor.CGColor;
            cell.layer.borderWidth = 2.f;
        }else{
            cell.layer.borderWidth = 0.f;
        }
        [self.scrollView addSubview:cell];

        // 设置每张图片的坐标，z值和透明度
        CGPoint pointMove = CGPointMake(index*viewSize.width/self.xMarginValue, 0);
        float zPosition = -index*viewSize.width/self.zMarginValue;
        float alpha = 1 - index*viewSize.width/self.alphaValue;
        
        PFlowViewCell  *moveCell = [self.dataSource pFlowView:self cellForItemAtIndex:index];
        moveCell.tag = index+kTagOffset;
        moveCell.frame = CGRectMake(pointMove.x, pointMove.y, viewSize.width,viewSize.height);
        moveCell.layer.transform = CATransform3DMakeRotation(self.angleValue, 0, -1, 0);//设置角度
        moveCell.layer.zPosition = zPosition; // Z坐标
        moveCell.alpha = alpha;
        //添加到视图与数组中
        if(index == self.currentIndex){
            moveCell.hidden = YES;
        }else{
            moveCell.hidden = NO;
        }

        //设置图片的阴影
        UIBezierPath* shadowPath1 = [UIBezierPath bezierPathWithRect:moveCell.bounds];
        moveCell.layer.shadowPath = shadowPath1.CGPath;
        moveCell.layer.shadowOffset = CGSizeMake(self.shadowValueX, self.shadowValueY);
        moveCell.layer.shadowOpacity = self.shadowAlpha;
        //设置边框
        if(self.borderColor){
            moveCell.layer.borderColor = self.borderColor.CGColor;
            moveCell.layer.borderWidth = 2.f;
        }else{
            moveCell.layer.borderWidth = 0.f;
        }

        [self.moveView addSubview:moveCell];
        
    }
}


- (void)removeObjectAtIndex:(NSInteger)index
{
    PFlowViewCell  *cell = [self cellForItemAtIndex:index];
    [self queueReusableCell:cell];
    PFlowViewCell  *moveCell = [self cellForItemInMoveViewAtIndex:index];
    [self queueReusableCell:moveCell];
}


- (UIImage *)imageWithSize:(UIImage *)image toSize:(CGSize)reSize //按尺寸缩放图片
{
    UIGraphicsBeginImageContext(reSize);
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

#pragma mark - PFlowViewDataSource
- (NSInteger)dataSourceNumberOfItems {
	if ([self.dataSource respondsToSelector:@selector(numberOfItemsInPFlowView:)]) {
		return [self.dataSource numberOfItemsInPFlowView:self];
	} else {
		return 0;
	}
}


#pragma mark UIScrollView delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView //滚动时处理
{
    
    float offset_x = scrollView.contentOffset.x;
    float width = scrollView.frame.size.width; //视图宽度
    self.currentIndex = roundf(offset_x/width); //得到索引
    
    [self relayoutItems];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //调整所有图片的z值
    for(PFlowViewCell * cell in [self.scrollView subviews]){
        cell.layer.zPosition = 0;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView //滚动结束处理
{
    self.lastIndexSelected = self.currentIndex;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gesture
{
    if([_delegate respondsToSelector:@selector(pFlowView:didSelectItemAtIndex:)]){
        [_delegate pFlowView:self didSelectItemAtIndex:self.currentIndex];
    }
}

#pragma mark - setter
- (void)setLastIndexSelected:(NSInteger)lastIndexSelected{
    if (_lastIndexSelected != lastIndexSelected) {
        _lastIndexSelected = lastIndexSelected;
        
        [self loadRequiredItems];
        [self relayoutItems];
    }
}

#pragma mark - getter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.contentOffset = CGPointMake(0, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.autoresizingMask = YES;
        _scrollView.clipsToBounds = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)]; //创建点击手势
        [_scrollView addGestureRecognizer:tapGestureRecognizer];
    }
    return _scrollView;
}

- (UIView *)moveView{
    if (!_moveView) {
        _moveView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _moveView;
}

@end
