//
//  BContactBookModule.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/04/2017.
//
//

#import "BAudioMessageModule.h"
#import "BFirebaseAudioMessageHandler.h"

#import <ChatSDK/Core.h>
#import <ChatSDK/UI.h>


@implementation BAudioMessageModule

-(void) activate {
    [BNetworkManager sharedManager].a.audioMessage = [[BFirebaseAudioMessageHandler alloc] init];
}

@end
