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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    
    self.contentSize = [self isHorizontal] ? CGSizeMake(5000, self.frame.size.height) : CGSizeMake(self.frame.size.width, 50000) ;

    self.elementContainerView.frame = [self isHorizontal] ? CGRectMake(0, 0, self.contentSize.width, self.contentSize.height/2) : CGRectMake(0, 0, self.contentSize.width/2, self.contentSize.height) ;
    
    
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.elementContainerView];
//    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
//    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    if([self isHorizontal]){
        CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
        CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
        [self tileLabelsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
    }else{
        CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
        CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
        [self tileLabelsFromMinX:minimumVisibleY toMaxX:maximumVisibleY];
    }
    
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        
        self.contentSize = [self isHorizontal] ? CGSizeMake(5000, self.frame.size.height) : CGSizeMake(self.frame.size.width, 50000) ;
        
        self.visibleElements = [[NSMutableArray alloc] init];
        
        self.elementContainerView = [[UIView alloc]init];
        
        self.elementContainerView.frame = [self isHorizontal] ? CGRectMake(0, 0, self.contentSize.width, self.contentSize.height/2) : CGRectMake(0, 0, self.contentSize.width/2, self.contentSize.height) ;
        
        [self addSubview:self.elementContainerView];
        
         [self.elementContainerView setUserInteractionEnabled:NO];
        
        //[self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        //[self showsHorizontalScrollIndicator:NO]
        [self setShowsHorizontalScrollIndicator:YES];
        [self setShowsVerticalScrollIndicator:YES];
        [self setUserInteractionEnabled:YES];
        
        self.userInteractionEnabled = YES;
        self.elementContainerView.userInteractionEnabled = YES;
        
    }
    return self;
}

-(void) recenterIfNecessary {
    
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWith   = [self contentSize].width;
    CGFloat contentHeight   = [self contentSize].height;
    CGFloat centerOffsetX = (contentWith - [self bounds].size.width)/2.0;
    CGFloat centerOffsetY = (contentHeight - [self bounds].size.height)/2.0;
    CGFloat distanceFromCenterInX = fabs(currentOffset.x - centerOffsetX);
    CGFloat distanceFromCenterInY = fabs(currentOffset.y - centerOffsetY);
    
    if([self isHorizontal]){
        if( distanceFromCenterInX > (contentWith/4.0) ){
            
            self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
            
            //move content if there is
            for (UILabel *label in self.visibleElements) {
                CGPoint center = [self.elementContainerView convertPoint:label.center toView:self];
                center.x += (centerOffsetX - currentOffset.x);
                label.center = [self convertPoint:center toView:self.elementContainerView];
            }
            
        }
    }else{
        if( distanceFromCenterInY > (contentHeight/4.0) ){
            
            self.contentOffset = CGPointMake(centerOffsetY, currentOffset.x);
            
            //move content if there is
            for (UILabel *label in self.visibleElements) {
                CGPoint center = [self.elementContainerView convertPoint:label.center toView:self];
                center.y += (centerOffsetY - currentOffset.y);
                label.center = [self convertPoint:center toView:self.elementContainerView];
            }
            
        }
        
    }
    
    
}


#pragma mark - Label Tiling

- (UILabel *)insertLabel
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self isHorizontal] ? (self.frame.size.width/3.0) : self.frame.size.width, [self isHorizontal] ? self.frame.size.height : (self.frame.size.height/3.0))];
    
   //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                               [self isHorizontal] ? (self.frame.size.width/3.0) : (self.frame.size.width/2.0),
                                                               [self isHorizontal] ? (self.frame.size.height/2.0) : (self.frame.size.height/3.0))];
                                                                     
    
    unsigned long indexForString = [[[self elementContainerView] subviews]count] % [[self stringsToPrint]count];
    
    NSString *toShowString = (NSString *)[[self stringsToPrint] objectAtIndex:indexForString];
    
    [label setNumberOfLines:3];
    
    [label setText:toShowString != nil ? toShowString : @"Pleaseanton \n CA\n 04350"];
    [label setFont:[UIFont systemFontOfSize:30]];
    [self.elementContainerView addSubview:label];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [label addGestureRecognizer:tapGestureRecognizer];
    label.userInteractionEnabled = YES;
    
    [tapGestureRecognizer setDelegate:self];
    
    return label;
}

- (void) labelTapped: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    UILabel *labelTapped = (UILabel *)[recognizer view];
    
    [labelTapped setAdjustsFontSizeToFitWidth:YES];
    [labelTapped setMinimumScaleFactor:0.5];
    
    [labelTapped setNeedsLayout];
}

- (CGFloat)placeNewLabelOnRight:(CGFloat)rightEdge
{
    UILabel *label = [self insertLabel];
    [self.visibleElements addObject:label]; // add rightmost label at the end of the array
    
    CGRect frame = [label frame];
    if([self isHorizontal]){
        frame.origin.x = rightEdge;
        frame.origin.y = [self.elementContainerView bounds].size.height - frame.size.height;
    }else{
        frame.origin.y = rightEdge;
        frame.origin.x = [self.elementContainerView bounds].size.width - frame.size.width;
    }
    
    [label setFrame:frame];
    
    return [self isHorizontal] ? CGRectGetMaxX(frame) : CGRectGetMaxY(frame);
    
}

- (CGFloat)placeNewLabelOnLeft:(CGFloat)leftEdge
{
    UILabel *label = [self insertLabel];
    [self.visibleElements insertObject:label atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [label frame];
    
    if([self isHorizontal]){
        frame.origin.x = leftEdge - frame.size.width;
        frame.origin.y = [self.elementContainerView bounds].size.height - frame.size.height;
    }else{
        frame.origin.y = leftEdge - frame.size.height;
        frame.origin.x = [self.elementContainerView bounds].size.width - frame.size.width;
    }
    
    
    [label setFrame:frame];
    
    return [self isHorizontal] ? CGRectGetMinX(frame) : CGRectGetMinY(frame);
}

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([self.visibleElements count] == 0)
    {
        [self placeNewLabelOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    UILabel *lastLabel = [self.visibleElements lastObject];
    CGFloat rightEdge = [self isHorizontal] ?  CGRectGetMaxX([lastLabel frame]) : CGRectGetMaxY([lastLabel frame]);
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewLabelOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UILabel *firstLabel = self.visibleElements[0];
    CGFloat leftEdge = [self isHorizontal] ? CGRectGetMinX([firstLabel frame]) : CGRectGetMinY([firstLabel frame]) ;
    while (leftEdge > minimumVisibleX)
    {
        leftEdge = [self placeNewLabelOnLeft:leftEdge];
    }
    
    // remove labels that have fallen off right edge
    lastLabel = [self.visibleElements lastObject];
    while ([lastLabel frame].origin.x > maximumVisibleX)
    {
        [lastLabel removeFromSuperview];
        [self.visibleElements removeLastObject];
        lastLabel = [self.visibleElements lastObject];
    }
    
    // remove labels that have fallen off left edge
    if ([self.visibleElements count] == 0){
        
        firstLabel = self.visibleElements[0];
        if([self isHorizontal]){
            while (CGRectGetMaxX([firstLabel frame]) < minimumVisibleX)
            {
                [firstLabel removeFromSuperview];
                [self.visibleElements removeObjectAtIndex:0];
                firstLabel = self.visibleElements[0];
            }
        }else{
            
            while (CGRectGetMaxY([firstLabel frame]) < minimumVisibleX)
            {
                [firstLabel removeFromSuperview];
                [self.visibleElements removeObjectAtIndex:0];
                firstLabel = self.visibleElements[0];
            }
            
        }
        
    }
    
    
}

@end
