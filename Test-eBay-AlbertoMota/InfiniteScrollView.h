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
    @property double lateralMargins;
    @property double topBottomMargins;
    @property int numOFElementsVisibles;
    @property (strong,nonatomic) NSArray *dictArray;
    -(void) reloadView;
@end
