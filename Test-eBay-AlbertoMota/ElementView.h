//
//  ElementView.h
//  Test-eBay-AlbertoMota
//
//  Created by Al on 4/26/18.
//  Copyright © 2018 Alberto Mota. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ElementView : UIView
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


@end
