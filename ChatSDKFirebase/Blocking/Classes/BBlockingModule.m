//
//  BBroadcastModule.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 30/05/2017.
//
//

#import "BBlockingModule.h"
#import <ChatSDK/Core.h>
#import "BBlockingHandler.h"

@implementation BBlockingModule

-(void) activate {
    [BNetworkManager sharedManager].a.blocking = [[BBlockingHandler alloc] init];
}

@end
