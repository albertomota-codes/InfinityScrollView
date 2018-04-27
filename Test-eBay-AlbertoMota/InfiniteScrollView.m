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

-(void) reloadImage{
    
    
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
        
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
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

- (UIView *)insertLabel
{
 
    CGRect baseGCRect = CGRectMake(0, 0, [self isHorizontal] ? (self.frame.size.width/3.0) : self.frame.size.width, [self isHorizontal] ? self.frame.size.height : (self.frame.size.height/3.0));
    
    ElementView *containerView = [[[NSBundle mainBundle] loadNibNamed:@"ElementView" owner:self options:nil] objectAtIndex:0];
    
    containerView.frame = baseGCRect;
    
//    if([[[self elementContainerView] subviews]count] % 2 == 0){
//        [containerView setBackgroundColor:[UIColor redColor]];
//    }else{
//        [containerView setBackgroundColor:[UIColor greenColor]];
//    }
    
    //containerView.mainImage.isHidden = ![self showImages];
    [[containerView mainImage]setHidden:![self showImages]];
    
    unsigned long indexForString = [[[self elementContainerView] subviews]count] % [[self stringsToPrint]count];
    
    NSString *toShowString = (NSString *)[[self stringsToPrint] objectAtIndex:indexForString];
    
    [[containerView mainLabel] setNumberOfLines:3];
    [[containerView mainLabel] setText:toShowString != nil ? toShowString : @"ERRRRROOOOORR \n ERRRRROOOOORR\n ERRRRROOOOORR"];
    [[containerView mainLabel] setFont:[UIFont systemFontOfSize:20]];

    [self.elementContainerView addSubview:containerView];
    
    //[label setBackgroundColor:[UIColor yellowColor]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [[containerView mainLabel] addGestureRecognizer:tapGestureRecognizer];
    [containerView mainLabel].userInteractionEnabled = YES;
    containerView.userInteractionEnabled = YES;
    [tapGestureRecognizer setDelegate:self];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [containerView setNeedsLayout];
//        [[containerView mainLabel] setNeedsUpdateConstraints];
//    });
    
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

- (CGFloat)placeNewLabelOnRight:(CGFloat)rightEdge
{
    UIView *insertedView = [self insertLabel];
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

- (CGFloat)placeNewLabelOnLeft:(CGFloat)leftEdge
{
    UIView *insertedView = [self insertLabel];
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

- (void)tileLabelsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([self.visibleElements count] == 0)
    {
        [self placeNewLabelOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    UIView *lastLabel = [self.visibleElements lastObject];
    CGFloat rightEdge = [self isHorizontal] ?  CGRectGetMaxX([lastLabel frame]) : CGRectGetMaxY([lastLabel frame]);
    while (rightEdge < maximumVisibleX)
    {
        rightEdge = [self placeNewLabelOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UIView *firstLabel = self.visibleElements[0];
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
