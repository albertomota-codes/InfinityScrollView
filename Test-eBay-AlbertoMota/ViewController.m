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

@interface ViewController ()
    //@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISwitch *isVerticalSwitch;
@property (strong,nonatomic) NSArray *elements;
@property (weak, nonatomic) IBOutlet InfiniteScrollView *infiniteScrollView;
@property (weak, nonatomic) IBOutlet UISwitch *showImageSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lateralMarginLabel;
@property (weak, nonatomic) IBOutlet UILabel *topBottomMarginLabel;

@property (weak, nonatomic) IBOutlet UISlider *lateralMarginSlider;
@property (weak, nonatomic) IBOutlet UISlider *topBottomMarginSlider;
@property (weak, nonatomic) IBOutlet UISlider *numberOfItemSlider;
@property (weak, nonatomic) IBOutlet UILabel *numberOfItemsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int limitSongs = 25;
    int initLateral = 16;
    int initTopBottom = 32;
    int initNumOfItems = 2;

    //NSMutableArray *arrayOfStrings = [NSMutableArray arrayWithCapacity:limitSongs];
    //[[self infiniteScrollView] setStringsToPrint:@[@"Hello"]];
    [[self infiniteScrollView] setDictArray:@[@{@"text":@"ejemplo"}]];
    [[self infiniteScrollView] setIsHorizontal:NO];
    [[self infiniteScrollView] setShowImages:YES];
    [[self infiniteScrollView] setLateralMargins:initLateral];
    [[self infiniteScrollView] setTopBottomMargins:initTopBottom];
    [[self infiniteScrollView] setNumOFElementsVisibles:initNumOfItems];
    
    [[self lateralMarginSlider] setValue:initLateral];
    [[self topBottomMarginSlider] setValue:initTopBottom];
    [[self numberOfItemSlider] setValue:initNumOfItems];
    
    [[self lateralMarginLabel]setText:[NSString stringWithFormat:@"%d",initLateral]];
    [[self topBottomMarginLabel]setText:[NSString stringWithFormat:@"%d",initTopBottom]];
    [[self numberOfItemsLabel]setText:[NSString stringWithFormat:@"%d",initNumOfItems]];
    
    
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
                                                          
                                                          NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:limitSongs];
                                                          
                                                          for ( NSDictionary *dict in (NSArray *)jsonResponse[@"results"] ){

                                                              
                                                              NSString *toStoreString = [NSString stringWithFormat:@"%@\n%@\n%@",[dict objectForKey:@"primaryGenreName"],[dict objectForKey:@"artistName"],[dict objectForKey:@"trackName"]];
                                                              [dictArray addObject:@{@"text":toStoreString,@"imageURl":[dict objectForKey:@"artworkUrl100"]}];
                                                              
                                                          }

                                                          
                                                          [[self infiniteScrollView] setDictArray:dictArray];
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                             [[self infiniteScrollView] reloadView];
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
   [[self infiniteScrollView] reloadView];
    
}
- (IBAction)showImageSwitchChanged:(id)sender {
    
    [[self infiniteScrollView] setShowImages:[(UISwitch *)sender isOn]];
    [[self infiniteScrollView] reloadView];
    
    
}
- (IBAction)lateralMarginsChanged:(id)sender {
    float value = [(UISlider *)sender value];
    [[self infiniteScrollView] setLateralMargins:value];
    [[self infiniteScrollView] reloadView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self lateralMarginLabel]setText:[NSString stringWithFormat:@"%.f",value]];
    });
    
    
}
- (IBAction)topBottomMarginChnaged:(id)sender {

    float value = [(UISlider *)sender value];
    
    [[self infiniteScrollView] setTopBottomMargins:value];
    [[self infiniteScrollView] reloadView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self topBottomMarginLabel]setText:[NSString stringWithFormat:@"%.f",value]];
    });
    
}
- (IBAction)numOfItemsChanged:(id)sender {
    
    UISlider * slider = (UISlider *)sender;
    
    float value = [slider value];
    [slider setValue:roundf(value)];
    value = [slider value];
    
    [[self infiniteScrollView] setNumOFElementsVisibles:value];
    [[self infiniteScrollView] reloadView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self numberOfItemsLabel]setText:[NSString stringWithFormat:@"%.f",value]];
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
