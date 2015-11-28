//
//  RecipeBookAppDelegate.m
//  RecipeBook
//
//  Created by Simon Ng on 14/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecipeBookAppDelegate.h"
#import "Play.h"
#import "Quotation.h"
#import "RecipeBookViewController.h"
@interface RecipeBookAppDelegate ()

@property (nonatomic, strong) NSArray *plays;
- (void)setUpPlaysArray;

@end

@implementation RecipeBookAppDelegate

@synthesize window = _window;
@synthesize  plays=plays_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//     [self setUpPlaysArray];
//    RecipeBookViewController *tableViewController = [[RecipeBookViewController alloc]init];
//    tableViewController.plays = self.plays;
    // Override point for customization after application launch.
    return YES;
}
- (void)setUpPlaysArray {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"PlaysAndQuotations" withExtension:@"plist"];
    NSArray *playDictionariesArray = [[NSArray alloc ] initWithContentsOfURL:url];
    NSMutableArray *playsArray = [NSMutableArray arrayWithCapacity:[playDictionariesArray count]];
    
    for (NSDictionary *playDictionary in playDictionariesArray) {
        
        Play *play = [[Play alloc] init];
        play.name = [playDictionary objectForKey:@"playName"];
        
        NSArray *quotationDictionaries = [playDictionary objectForKey:@"quotations"];
        NSMutableArray *quotations = [NSMutableArray arrayWithCapacity:[quotationDictionaries count]];
        
        for (NSDictionary *quotationDictionary in quotationDictionaries) {
            
            Quotation *quotation = [[Quotation alloc] init];
            [quotation setValuesForKeysWithDictionary:quotationDictionary];
            
            [quotations addObject:quotation];
        }
        play.quotations = quotations;
        
        [playsArray addObject:play];
    }
    
    self.plays = playsArray;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
