//
//  InfiniteScrollView.m
//  Test-eBay-AlbertoMota
//
//  Created by Al on 4/26/18.
//  Copyright © 2018 Alberto Mota. All rights reserved.
//

#import "InfiniteScrollView.h"
#import "ElementView.h"

@interface InfiniteScrollView ()
    @property (strong,nonatomic) NSMutableArray *visibleElements;
    @property (strong,nonatomic) UIView *elementContainerView;

@end

@implementation InfiniteScrollView

-(void) reloadView{
    
    [[self visibleElements]removeAllObjects];
    for(UIView *view in [[self elementContainerView]subviews]){
        [view removeFromSuperview];
        [view setHidden:YES];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
        [self layoutSubviews];
    });
    
}

- (void)layoutSubviews {
    
    self.contentSize = [self isHorizontal] ? CGSizeMake(5000, self.frame.size.height) : CGSizeMake(self.frame.size.width, 50000) ;

    self.elementContainerView.frame = [self isHorizontal] ? CGRectMake(0, 0, self.contentSize.width, self.contentSize.height/2) : CGRectMake(0, 0, self.contentSize.width/2, self.contentSize.height) ;
    
    [super layoutSubviews];
    [self recenterIfNecessary];
    
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.elementContainerView];
    
//    if([self isHorizontal]){
//        CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
//        CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
//        [self tileLabelsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
//    }else{
//        CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
//        CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
//        [self tileLabelsFromMinX:minimumVisibleY toMaxX:maximumVisibleY];
//    }
    
    CGFloat minimumVisible = [self isHorizontal] ? CGRectGetMinX(visibleBounds) : CGRectGetMinY(visibleBounds);
    CGFloat maximumVisible = [self isHorizontal] ? CGRectGetMaxX(visibleBounds) : CGRectGetMaxY(visibleBounds);
    [self tileViewsFromMinX:minimumVisible toMaxX:maximumVisible];
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        
        self.contentSize = [self isHorizontal] ? CGSizeMake(5000, self.frame.size.height) : CGSizeMake(self.frame.size.width, 50000) ;
        
        self.visibleElements        = [[NSMutableArray alloc] init];
        self.elementContainerView   = [[UIView alloc]init];
        
        self.elementContainerView.frame = [self isHorizontal] ? CGRectMake(0, 0, self.contentSize.width, self.contentSize.height/[self numOFElementsVisibles]) : CGRectMake(0, 0, self.contentSize.width/[self numOFElementsVisibles], self.contentSize.height) ;
        
        [self addSubview:self.elementContainerView];

        [self.elementContainerView setUserInteractionEnabled:NO];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setUserInteractionEnabled:YES];
        [self.elementContainerView setUserInteractionEnabled:YES];
        
    }
    return self;
}

-(void) recenterIfNecessary {
    
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWith   = [self contentSize].width;
    CGFloat contentHeight = [self contentSize].height;
    CGFloat centerOffsetX = (contentWith - [self bounds].size.width)/2.0;
    CGFloat centerOffsetY = (contentHeight - [self bounds].size.height)/2.0;
    
    CGFloat distanceFromCenterInX = fabs(currentOffset.x - centerOffsetX);
    CGFloat distanceFromCenterInY = fabs(currentOffset.y - centerOffsetY);
    
    if([self isHorizontal]){
        if( distanceFromCenterInX > (contentWith/4.0) ){
            
            //self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
            self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
            
            //move content if there is
            for (UIView *view in self.visibleElements) {
                CGPoint center = [self.elementContainerView convertPoint:view.center toView:self];
                center.x += (centerOffsetX - currentOffset.x);
                view.center = [self convertPoint:center toView:self.elementContainerView];
            }
            
        }
    }else{
        if( distanceFromCenterInY > (contentHeight/4.0) ){
            
           // self.contentOffset = CGPointMake(centerOffsetY, currentOffset.x);
            self.contentOffset = CGPointMake(currentOffset.x,centerOffsetY );
            
            //move content if there is
            for (UIView *view in self.visibleElements) {
                CGPoint center = [self.elementContainerView convertPoint:view.center toView:self];
                center.y += (centerOffsetY - currentOffset.y);
                view.center = [self convertPoint:center toView:self.elementContainerView];
            }
            
        }
        
    }
    
    
}

#pragma mark - Label Tiling

- (UIView *)insertView
{
  
    CGRect baseGCRect = CGRectMake(0, 0, [self isHorizontal] ? (self.frame.size.width/[self numOFElementsVisibles]) : self.frame.size.width, [self isHorizontal] ? self.frame.size.height : (self.frame.size.height/[self numOFElementsVisibles]));
    
    ElementView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"ElementView" owner:self options:nil] objectAtIndex:0];
    
    containerView.frame = baseGCRect;
    
//    if([[[self elementContainerView] subviews]count] % 2 == 0){
//        [containerView setBackgroundColor:[UIColor redColor]];
//    }else{
//        [containerView setBackgroundColor:[UIColor greenColor]];
//    }
    
    //containerView.mainImage.isHidden = ![self showImages];
    [[containerView mainImage]setHidden:![self showImages]];
    unsigned long indexForString = [[[self elementContainerView] subviews]count] % [[self dictArray]count];
    NSDictionary *elementInfo = (NSDictionary *)[[self dictArray]objectAtIndex:indexForString];
    
    if([self showImages]){
        
        
        NSURL *url = [NSURL URLWithString:
                      [elementInfo objectForKey:@"imageURl"]];
        
        // 2
        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                       downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                           // 3
                                                           UIImage *downloadedImage = [UIImage imageWithData:
                                                                                       [NSData dataWithContentsOfURL:location]];
                                                           
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [[containerView mainImage]setImage:downloadedImage];
                                                           });
                                                           
                                                       }];
        
        // 4
        [downloadPhotoTask resume];
    }
    
    

    [containerView leadingConstraint].constant  = [self lateralMargins];
    [containerView trailingConstraint].constant = [self lateralMargins];
    [containerView topConstraint].constant      = [self topBottomMargins];
    [containerView bottomConstraint].constant   = [self topBottomMargins];
    [[containerView mainLabel] setNumberOfLines:3];
    [[containerView mainLabel] setText:elementInfo[@"text"] != nil ? elementInfo[@"text"] : @"ERRRRROOOOORR \n ERRRRROOOOORR\n ERRRRROOOOORR"];
    [[containerView mainLabel] setFont:[UIFont systemFontOfSize:20]];

    [self.elementContainerView addSubview:containerView];
    
    [[containerView mainLabel] setBackgroundColor:[UIColor lightGrayColor]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [[containerView mainLabel] addGestureRecognizer:tapGestureRecognizer];
    [containerView mainLabel].userInteractionEnabled = YES;
    containerView.userInteractionEnabled = YES;
    [tapGestureRecognizer setDelegate:self];
    
    
    return containerView;
}

- (void) labelTapped: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    UILabel *labelTapped = (UILabel *)[recognizer view];
    
    [labelTapped setAdjustsFontSizeToFitWidth:YES];
    [labelTapped setMinimumScaleFactor:0.5];
    dispatch_async(dispatch_get_main_queue(), ^{
        [labelTapped setNeedsLayout];
        [[labelTapped superview] setNeedsLayout];
    });
}

- (CGFloat)placeNewViewOnRight:(CGFloat)rightEdge
{
    UIView *insertedView = [self insertView];
    [self.visibleElements addObject:insertedView]; // add rightmost label at the end of the array
    
    CGRect frame = [insertedView frame];
    if([self isHorizontal]){
        frame.origin.x = rightEdge;
        //frame.origin.y = [self.elementContainerView bounds].size.height - frame.size.height;
    }else{
        frame.origin.y = rightEdge;
        //frame.origin.x = [self.elementContainerView bounds].size.width - frame.size.width;
    }
    
    [insertedView setFrame:frame];
    
    return [self isHorizontal] ? CGRectGetMaxX(frame) : CGRectGetMaxY(frame);
    
}

- (CGFloat)placeNewViewOnLeft:(CGFloat)leftEdge
{
    UIView *insertedView = [self insertView];
    [self.visibleElements insertObject:insertedView atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [insertedView frame];
    
    if([self isHorizontal]){
        frame.origin.x = leftEdge - frame.size.width;
        //frame.origin.y = [self.elementContainerView bounds].size.height - frame.size.height;
    }else{
        frame.origin.y = leftEdge - frame.size.height;
        //frame.origin.x = [self.elementContainerView bounds].size.width - frame.size.width;
    }
    
    
    [insertedView setFrame:frame];
    
    return [self isHorizontal] ? CGRectGetMinX(frame) : CGRectGetMinY(frame);
}

- (void)tileViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{

    if ([self.visibleElements count] == 0)
    {
        [self placeNewViewOnRight:minimumVisibleX];
    }
    
    UIView *lastView = [self.visibleElements lastObject];
    CGFloat rightEdge = [self isHorizontal] ?  CGRectGetMaxX([lastView frame]) : CGRectGetMaxY([lastView frame]);
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewViewOnRight:rightEdge];
    }
    
    UIView *firstView = self.visibleElements[0];
    CGFloat leftEdge = [self isHorizontal] ? CGRectGetMinX([firstView frame]) : CGRectGetMinY([firstView frame]) ;
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewViewOnLeft:leftEdge];
    }
    
    lastView = [self.visibleElements lastObject];
    while ([lastView frame].origin.x > maximumVisibleX)
    {
        [lastView removeFromSuperview];
        [self.visibleElements removeLastObject];
        lastView = [self.visibleElements lastObject];
    }
    
    // remove labels that have fallen off left edge
    if ([self.visibleElements count] == 0){
        
        firstView = self.visibleElements[0];
        if([self isHorizontal]){
            while (CGRectGetMaxX([firstView frame]) < minimumVisibleX)
            {
                [firstView removeFromSuperview];
                [self.visibleElements removeObjectAtIndex:0];
                firstView = self.visibleElements[0];
            }
        }else{
            
            while (CGRectGetMaxY([firstView frame]) < minimumVisibleX)
            {
                [firstView removeFromSuperview];
                [self.visibleElements removeObjectAtIndex:0];
                firstView = self.visibleElements[0];
            }
            
        }
        
    }
    
    
}

@end
