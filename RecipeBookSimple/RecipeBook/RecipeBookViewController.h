//
//  RecipeBookViewController.h
//  RecipeBook
//
//  Created by Simon Ng on 14/6/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SectionHeaderView.h"
@class QuoteCell;
@interface RecipeBookViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate,SectionHeaderViewDelegate>
@property (nonatomic, strong) NSArray* plays;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet QuoteCell *quoteCell;
@end
