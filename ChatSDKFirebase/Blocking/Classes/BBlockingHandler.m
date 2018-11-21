//
//  BBroadcastHandler.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 30/05/2017.
//
//

#import "BBlockingHandler.h"

#import <ChatSDK/Core.h>
#import "ChatSDKFirebase/FirebaseAdapter.h"

#define bBlockedPath @"blocked"

@implementation BBlockingHandler

-(id) init {
    if((self = [super init])) {
        _blockedUsers = [NSMutableArray new];
        
        [NM.hook addHook:[BHook hook:^(NSDictionary * value) {
            [self on];
        }] withName: bHookUserAuthFinished];
        
    }
    return self;
}

-(void) on {
    FIRDatabaseReference * ref = self.ref;
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * snapshot) {
        if(![_blockedUsers containsObject:snapshot.key]) {
            [_blockedUsers addObject:snapshot.key];
        }
    }];
    [ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * snapshot) {
        if([_blockedUsers containsObject:snapshot.key]) {
            [_blockedUsers removeObject:snapshot.key];
        }
    }];
}

-(RXPromise *) blockUser: (NSString *) userEntityID {
    RXPromise * promise = [RXPromise new];
    
    [[self.ref child:userEntityID] setValue:@{bUID: userEntityID} withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref) {
        if(!error) {
            [promise resolveWithResult:Nil];
        }
        else {
            [promise rejectWithReason:error];
        }
    }];
    
    return promise;
}

-(RXPromise *) unblockUser: (NSString *) userEntityID {
    RXPromise * promise = [RXPromise new];

    [[self.ref child:userEntityID] removeValueWithCompletionBlock:^(NSError * error, FIRDatabaseReference * ref) {
        if(!error) {
            [promise resolveWithResult:Nil];
        }
        else {
            [promise rejectWithReason:error];
        }
    }];

    return promise;
}

-(BOOL) isBlocked: (NSString *) userEntityID {
    return [_blockedUsers containsObject:userEntityID];
}

-(FIRDatabaseReference *) ref {
    return [[FIRDatabaseReference userRef:NM.currentUser.entityID] child:bBlockedPath];
}

@end
