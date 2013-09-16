//
//  CustomPFlowViewCell.m
//  PFlowView
//
//  Created by JK.PENG on 13-9-15.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "CustomPFlowViewCell.h"
#import "UIImageView+WebCache.h"

@implementation CustomPFlowViewCell
@synthesize imageView = _imageView;
@synthesize urlStr = _urlStr;

- (void)dealloc{
    [self.imageView resetImage];
    self.imageView = nil;
    self.urlStr = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView.frame = self.bounds;
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self.imageView resetImage];
}

#pragma mark - getter
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.userInteractionEnabled = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - setter
- (void)setUrlStr:(NSString *)urlStr{
    if (urlStr != _urlStr) {
        _urlStr = urlStr;
    }
    
    [self.imageView setImageWithURLString:_urlStr];

}

@end
