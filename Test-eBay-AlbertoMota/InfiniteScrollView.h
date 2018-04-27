//
//  InfiniteScrollView.h
//  Test-eBay-AlbertoMota
//
//  Created by Al on 4/26/18.
//  Copyright © 2018 Alberto Mota. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfiniteScrollView : UIScrollView<UIGestureRecognizerDelegate>
    @property bool isHorizontal;
    @property bool showImages;
    @property (strong,nonatomic) NSArray *stringsToPrint;
    -(void) reloadImage;
@end
