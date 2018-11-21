//
//  BContactBookModule.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/04/2017.
//
//

#import "BReadReceiptsModule.h"

#import <ChatSDK/Core.h>
#import <ChatSDK/UI.h>
#import "BFirebaseReadReceiptHandler.h"


@implementation BReadReceiptsModule

-(void) activate {
    [BNetworkManager sharedManager].a.readReceipt = [[BFirebaseReadReceiptHandler alloc] init];
}

@end
