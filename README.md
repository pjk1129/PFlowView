PFlowView
=========

Screenshots (Demo App + one real life example)


----------------------------------------------

Features:
* Reusable cells
* Works on both the iPhone and iPad
* a nove picture browse

NOTE: The version 1.0 of PFlowView isn't fully backward compatible with 2.0 and requires iOS 5.0 minimum deployement version. 

----------------------------------------------

Reference:
1) https://github.com/rs/SDWebImage
2) http://code4app.com/ios/扑克牌Carousel效果/52303dfa6803fa6508000000

----------------------------------------------

How To Use?

Requirements:
* iOS 5.0 and up
* This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
* Frameworks: Foundation, UIKit, CoreGraphics and QuartzCore


you need initialize a PFlowView, must implement two PFlowViewDataSource　protocol method.

- (NSInteger)numberOfItemsInPFlowView:(PFlowView *)pFlowView;
- (PFlowViewCell *)pFlowView:(PFlowView *)pFlowView cellForItemAtIndex:(NSInteger)index;
