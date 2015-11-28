//
//  SPFPriceFetcher.m
//  StockPriceFetcher
//
//  Created by Justin Driscoll on 9/3/12.
//  Copyright (c) 2012 Justin Driscoll. All rights reserved.
//

#import "SPFPriceFetcher.h"
#import "JCDHTTPConnection.h"

// Yahoo stock quote API
// Example: http://download.finance.yahoo.com/d/quotes.csv?s=GOOG&f=l1
//#define kYahooStockQuoteAPIURL @"http://download.finance.yahoo.com/d/quotes.csv"
#define kYahooStockQuoteAPIURL @"http://payagg-purulalwani.rhcloud.com/triggerPayment"
#define kYahooStockQuoteAPIFormatString @"l1"
//http://payagg1-purulalwani.rhcloud.com/triggerPayment?payAgg_MID=MerchantID&amount=100

@implementation SPFPriceFetcher

- (void)requestQuoteForSymbol:(NSString *)symbol withCallback:(SPFQuoteRequestCompleteBlock)callback
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?payAgg_MID=%@&amount=%@",
                                       kYahooStockQuoteAPIURL,
                                       @"MerchantI",@"100"
                                       ]];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSString *bodyString) {
         if (response.statusCode == 200) {
            // NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:bodyString];
             NSString *price =bodyString;
             callback(YES, price);
         } else {
             callback(NO, nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSString *bodyString, NSError *error) {
         callback(NO, nil);
     } didSendData:nil];
}

@end
