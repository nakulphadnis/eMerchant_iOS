//
//  RecipeBookViewController.m
//  RecipeBook
//
//  Created by Simon Ng on 14/6/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "RecipeBookViewController.h"
#import "RecipeDetailViewController.h"
#import "QuoteCell.h"
#import "HighlightingTextView.h"
#import "SectionInfo.h"
#import "SectionHeaderView.h"

#import "Play.h"
#import "Quotation.h"

#import "SPFPriceFetcher.h"

#define DEFAULT_ROW_HEIGHT 78
#define HEADER_HEIGHT 45

@interface RecipeBookViewController ()
@property (strong, nonatomic) SPFPriceFetcher *quoter;


@property (nonatomic, strong) NSMutableArray* sectionInfoArray;
@property (nonatomic, strong) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;

// Use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously.
@property (nonatomic, assign) NSInteger uniformRowHeight;

-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath;

-(void)emailMenuButtonPressed:(UIMenuController*)menuController;
-(void)sendEmailForEntryAtIndexPath:(NSIndexPath*)indexPath;

@end

@implementation RecipeBookViewController {
    NSArray *recipes;
    NSDictionary *products;
    NSArray *productsSectionTitles;
}

@synthesize tableView;





@synthesize plays=plays_, sectionInfoArray=sectionInfoArray_, quoteCell=newsCell_, pinchedIndexPath=pinchedIndexPath_, uniformRowHeight=rowHeight_, openSectionIndex=openSectionIndex_, initialPinchHeight=initialPinchHeight_;

- (void)viewDidLoad {
	
    [super viewDidLoad];
    products = @{@"Mobile" : @[@"iPhone 6", @"Samsung", @"HTC"],
                 @"Clothes" : @[@"Raymonds", @"Peter England"],
                 @"Cosmetics" : @[@"P&G", @"Fiama di wills"],
                 @"Electronics" : @[@"L&G",@"Samsung"],
                 //                @"G" : @[@"Giraffe", @"Greater Rhea"],
                 //                @"H" : @[@"Hippopotamus", @"Horse"],
                 //                @"K" : @[@"Koala"],
                 //                @"L" : @[@"Lion", @"Llama"],
                 //                @"M" : @[@"Manatus", @"Meerkat"],
                 //                @"P" : @[@"Panda", @"Peacock", @"Pig", @"Platypus", @"Polar Bear"],
                 //                @"R" : @[@"Rhinoceros"],
                 //                @"S" : @[@"Seagull"],
                 //                @"T" : @[@"Tasmania Devil"],
                 //                @"W" : @[@"Whale", @"Whale Shark", @"Wombat"]
                 };
    
    productsSectionTitles = [[products allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    // Add a pinch gesture recognizer to the table view.
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.tableView addGestureRecognizer:pinchRecognizer];
    
    // Set up default values.
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
	/*
     The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
     */
    rowHeight_ = DEFAULT_ROW_HEIGHT;
    openSectionIndex_ = NSNotFound;
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
    /*
     Check whether the section info array has been created, and if so whether the section count still matches the current section count. In general, you need to keep the section info synchronized with the rows and section. If you support editing in the table view, you need to appropriately update the section info during editing operations.
     */
	if ((self.sectionInfoArray == nil) || ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.tableView])) {
		
        // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
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

		for (Play *play in self.plays) {
			
			SectionInfo *sectionInfo = [[SectionInfo alloc] init];
			sectionInfo.play = play;
			sectionInfo.open = NO;
			
            NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
			NSInteger countOfQuotations = [[sectionInfo.play quotations] count];
			for (NSInteger i = 0; i < countOfQuotations; i++) {
				[sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
			}
			
			[infoArray addObject:sectionInfo];
		}
		
		self.sectionInfoArray = infoArray;
	}
	
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.plays count];
    //return [productsSectionTitles count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
	NSInteger numStoriesInSection = [[sectionInfo.play quotations] count];
	
    return sectionInfo.open ? numStoriesInSection : 0;
//    NSString *sectionTitle = [productsSectionTitles objectAtIndex:section];
//    NSArray *sectionProducts = [products objectForKey:sectionTitle];
//    return [sectionProducts count];
//[recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *simpleTableIdentifier = @"RecipeCell";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
//    }
    static NSString *QuoteCellIdentifier = @"QuoteCellIdentifier";
    
    QuoteCell *cell = (QuoteCell*)[tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
    
    if (!cell) {
        
        UINib *quoteCellNib = [UINib nibWithNibName:@"QuoteCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.quoteCell;
        self.quoteCell = nil;
        
        if ([MFMailComposeViewController canSendMail]) {
            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            [cell addGestureRecognizer:longPressRecognizer];
        }
		else {
			NSLog(@"Mail not available");
		}
    }
    
    Play *play = (Play *)[[self.sectionInfoArray objectAtIndex:indexPath.section] play];
    cell.quotation = [play.quotations objectAtIndex:indexPath.row];

//    NSString *sectionTitle = [productsSectionTitles objectAtIndex:indexPath.section];
//    NSArray *sectionProducts = [products objectForKey:sectionTitle];
//    NSString *productName = [sectionProducts objectAtIndex:indexPath.row];
//    cell.textLabel.text = productName;
//    UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.origin.x+cell.frame.size.width-100,cell.frame.origin.y,cell.frame.size.width, cell.frame.size.height)];
//    
//    price.text=@"300.00";
//    cell.textLabel.textAlignment = UITextAlignmentLeft;
//    [cell.contentView addSubview:price];
//    cell.detailTextLabel.textAlignment =UITextAlignmentRight;
    

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //if ([segue.identifier isEqualToString:@"showRecipeDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
        SPFQuoteRequestCompleteBlock callback = ^(BOOL wasSuccessful, NSString *price) {
            if (wasSuccessful) {
                price =[price stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
                RecipeDetailViewController *destViewController = segue.destinationViewController;
                destViewController.recipeName = price;
                destViewController.payview.delegate=self;
                [destViewController.payview loadHTMLString:price baseURL:nil];
                
                     }
        };
        [self.quoter requestQuoteForSymbol:[recipes objectAtIndex:indexPath.row]
                              withCallback:callback];
   // }
}
-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionOpened];
	
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.play.quotations count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
		
		SectionInfo *previousOpenSection = [self.sectionInfoArray objectAtIndex:previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.play.quotations count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // Apply the updates.
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.tableView endUpdates];
    self.openSectionIndex = sectionOpened;
    
}


-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionClosed];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
    return [[sectionInfo objectInRowHeightsAtIndex:indexPath.row] floatValue];
    // Alternatively, return rowHeight.
}
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    /*
     Create the section header views lazily.
     */
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    if (!sectionInfo.headerView) {
		NSString *playName = sectionInfo.play.name;
        sectionInfo.headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, HEADER_HEIGHT) title:playName section:section delegate:self];
    }
    
    return sectionInfo.headerView;
}




-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//





#pragma mark Handling pinches


-(void)handlePinch:(UIPinchGestureRecognizer*)pinchRecognizer {
    
    /*
     There are different actions to take for the different states of the gesture recognizer.
     * In the Began state, use the pinch location to find the index path of the row with which the pinch is associated, and keep a reference to that in pinchedIndexPath. Then get the current height of that row, and store as the initial pinch height. Finally, update the scale for the pinched row.
     * In the Changed state, update the scale for the pinched row (identified by pinchedIndexPath).
     * In the Ended or Canceled state, set the pinchedIndexPath property to nil.
     */
    
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pinchLocation = [pinchRecognizer locationInView:self.tableView];
        NSIndexPath *newPinchedIndexPath = [self.tableView indexPathForRowAtPoint:pinchLocation];
		self.pinchedIndexPath = newPinchedIndexPath;
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:newPinchedIndexPath.section];
        self.initialPinchHeight = [[sectionInfo objectInRowHeightsAtIndex:newPinchedIndexPath.row] floatValue];
        // Alternatively, set initialPinchHeight = uniformRowHeight.
        
        [self updateForPinchScale:pinchRecognizer.scale atIndexPath:newPinchedIndexPath];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateForPinchScale:pinchRecognizer.scale atIndexPath:self.pinchedIndexPath];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) || (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchedIndexPath = nil;
        }
    }
}


-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath && (indexPath.section != NSNotFound) && (indexPath.row != NSNotFound)) {
        
		CGFloat newHeight = round(MAX(self.initialPinchHeight * scale, DEFAULT_ROW_HEIGHT));
        
		SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
        [sectionInfo replaceObjectInRowHeightsAtIndex:indexPath.row withObject:[NSNumber numberWithFloat:newHeight]];
        // Alternatively, set uniformRowHeight = newHeight.
        
        /*
         Switch off animations during the row height resize, otherwise there is a lag before the user's action is seen.
         */
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:animationsEnabled];
    }
}


#pragma mark Handling long presses

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    
    /*
     For the long press, the only state of interest is Began.
     When the long press is detected, find the index path of the row (if there is one) at press location.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
//            EmailMenuItem *menuItem = [[EmailMenuItem alloc] initWithTitle:@"Email" action:@selector(emailMenuButtonPressed:)];
//            menuItem.indexPath = pressedIndexPath;
//            menuController.menuItems = [NSArray arrayWithObject:menuItem];
//            [menuController setTargetRect:[self.tableView rectForRowAtIndexPath:pressedIndexPath] inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}


-(void)emailMenuButtonPressed:(UIMenuController*)menuController {
    
//    EmailMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
//    if (menuItem.indexPath) {
//        [self resignFirstResponder];
//        [self sendEmailForEntryAtIndexPath:menuItem.indexPath];
//    }
}


-(void)sendEmailForEntryAtIndexPath:(NSIndexPath*)indexPath {
    
	SectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:self.pinchedIndexPath.section];
    // In production, send the appropriate message.
    NSLog(@"Send email to %@", sectionInfo);
}


-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
    if (result == MFMailComposeResultFailed) {
        // In production, display an appropriate message to the user.
        NSLog(@"Mail send failed with error: %@", error);
    }
}


#pragma mark Memory management



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [productsSectionTitles objectAtIndex:section];
}

- (SPFPriceFetcher *)quoter
    {
        if (!_quoter) {
            self.quoter = [[SPFPriceFetcher alloc] init];
        }
        
        return _quoter;
    }



@end
