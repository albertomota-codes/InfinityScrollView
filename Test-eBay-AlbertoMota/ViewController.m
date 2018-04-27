//
//  ViewController.m
//  Test-eBay-AlbertoMota
//
//  Created by Al on 4/26/18.
//  Copyright © 2018 Alberto Mota. All rights reserved.
//

#import "ViewController.h"
//#import "InfiniteListControl.h"
#import "InfiniteScrollView.h"
#import "NSObject+NSString_Repeat.m"

@interface ViewController ()
    //@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISwitch *isVerticalSwitch;
@property (strong,nonatomic) NSArray *elements;
@property (weak, nonatomic) IBOutlet InfiniteScrollView *infiniteScrollView;
@property (weak, nonatomic) IBOutlet UISwitch *showImageSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int limitSongs = 25;

    NSMutableArray *arrayOfStrings = [NSMutableArray arrayWithCapacity:limitSongs];
    [[self infiniteScrollView] setStringsToPrint:@[@""]];
    [[self infiniteScrollView] setIsHorizontal:NO];
    [[self infiniteScrollView] setShowImages:YES];
    
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:[NSURL
                                                           URLWithString: [NSString stringWithFormat:@"https://itunes.apple.com/search?term=jack&limit=%d",limitSongs]]
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              // 4: Handle response here

                                              if (!error) {
                                                  // Success
                                                  if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                      NSError *jsonError;
                                                      NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                      
                                                      if (jsonError) {
                                                          // Error Parsing JSON
                                                          
                                                      } else {
                                                          // Success Parsing JSON
                                                          // Log NSDictionary response:
                                                          
                                                          //NSArray *results = (NSArray *)jsonResponse[@"results"]
                                                          [arrayOfStrings removeAllObjects];
                                                          for ( NSDictionary *dict in (NSArray *)jsonResponse[@"results"] ){

                                                              
                                                              NSString *toStoreString = [NSString stringWithFormat:@"%@\n%@\n%@",[dict objectForKey:@"primaryGenreName"],[dict objectForKey:@"artistName"],[dict objectForKey:@"trackName"]];
                                                              
                                                              [arrayOfStrings addObject:toStoreString];
                                                              
                                                          }
                                                          
                                                          
                                                          [[self infiniteScrollView] setStringsToPrint:[NSArray arrayWithArray:arrayOfStrings]];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [[self infiniteScrollView] setNeedsLayout];
                                                          });
                                                          
                                                      }
                                                  }  else {
                                                      //Web server is returning an error
                                                  }
                                              } else {
                                                  // Fail
                                                  NSLog(@"error : %@", error.description);
                                              }
                                          }];

    [downloadTask resume];
}
- (IBAction)horizontalValueChanged:(id)sender {
    
    
   [[self infiniteScrollView] setIsHorizontal:[(UISwitch *)sender isOn]];
    
   [[self infiniteScrollView] reloadImage];
    
}
- (IBAction)showImageSwitchChanged:(id)sender {
    
    [[self infiniteScrollView] setShowImages:[(UISwitch *)sender isOn]];
    [[self infiniteScrollView] reloadImage];
    
    
}

- (void) labelTapped: (UITapGestureRecognizer *)recognizer
{
    //Code to handle the gesture
    UILabel *labelTapped = (UILabel *)[recognizer view];
    
    [labelTapped setAdjustsFontSizeToFitWidth:YES];
    [labelTapped setMinimumScaleFactor:0.1];
    
    [labelTapped setNeedsLayout];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
