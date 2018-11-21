//
//  BFirebaseReadReceiptHandler.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/12/2016.
//
//

#import "BFirebaseReadReceiptHandler.h"

#import <ChatSDK/Core.h>
#import "ChatSDKFirebase/FirebaseAdapter.h"

// How old does a message have to be before we stop adding the
// read receipt listener
#define bReadReceiptMaxAge 7.0 * bDays
#define bReadPath @"read"

@implementation BFirebaseReadReceiptHandler

-(void) updateReadReceiptsForThread: (id<PThread>) thread {
    if (!(thread.type.intValue & bThreadFilterPrivate)) {
        return;
    }
    
    id<PUser> currentUser = NM.currentUser;
    for (id<PMessage> message in thread.messagesOrderedByDateAsc) {
        if ([message.userModel isEqual:currentUser]) {
            if ([self listenToReadReceiptsForMessage:message]) {
                [self messageReadReceiptsOn:message];
            }
            else {
                [self messageReadReceiptsOff: message];
            }
        }
        else {
            [self message: message setReadStatus: bMessageReadStatusDelivered];
        }
    }
}

-(void) markRead: (id<PThread>) thread {
    [thread markRead];
    if (NM.readReceipt) {
        for(id<PMessage> message in thread.allMessages) {
            if ([self markReadReceiptsForMessage:message]) {
                [self message: message setReadStatus: bMessageReadStatusRead];
            }
        }
    }
}

// Only listen to messages on private threads where we didn't
// send the message and the message was sent less than the max
// age ago
-(BOOL) listenToReadReceiptsForMessage: (id<PMessage>) message {
    id<PUser> currentUser = NM.currentUser;
    
    BOOL listen = message.thread.type.intValue & bThreadFilterPrivate && [message.userModel isEqual:currentUser] && [message.date timeIntervalSinceNow] < bReadReceiptMaxAge;
    
    BOOL allRead = YES;
    for (id<PUser> user in message.thread.users) {
        if ([message readStatusForUserID:user.entityID] != bMessageReadStatusRead && ![user.entityID isEqualToString:currentUser.entityID]) {
            allRead = NO;
        }
    }
    
    return listen && !allRead;
}

-(BOOL) markReadReceiptsForMessage: (id<PMessage>) message {
    id<PUser> currentUser = NM.currentUser;
    return message.thread.type.intValue & bThreadFilterPrivate && ![message.userModel isEqual:currentUser] && [message.date timeIntervalSinceNow] < bReadReceiptMaxAge;
}

-(void) messageReadReceiptsOn: (id<PMessage>) message {
    
    if (((NSManagedObject *) message).on) {
        return;
    }
    
    ((NSManagedObject *) message).on = YES;
    
    [[self messageReadRef: message] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * snapshot) {
        if (![snapshot.value isEqual: [NSNull null]]) {
            [message setReadStatus:snapshot.value];
            [[NSNotificationCenter defaultCenter] postNotificationName:bNotificationReadReceiptUpdated object:nil userInfo:@{bNotificationReadReceiptUpdatedKeyMessage: message}];
        }
    }];
}

-(void) messageReadReceiptsOff:(id<PMessage>) message {
    [[self messageReadRef: message] removeAllObservers];
    ((NSManagedObject *) message).on = NO;
}

-(RXPromise *) message: (id<PMessage>) message setReadStatus: (bMessageReadStatus) status {
    
    // Set our status area
    RXPromise * promise = [RXPromise new];
    NSString * uid = NM.currentUser.entityID;
    
    // Don't set read status for our own messages
    if([uid isEqualToString:message.userModel.entityID]) {
        [promise resolveWithResult:Nil];
        return promise;
    }
    
    // TODO: Why?
    if ([message readStatusForUserID:uid] == bMessageReadStatusHide) {
        [promise resolveWithResult:Nil];
        return promise;
    }
    
    // Check to see if we've already set the status?
    bMessageReadStatus currentStatus = [message readStatusForUserID:uid];
    
    // If the status is the same or lower than the new status just return
    if (currentStatus >= status) {
        [promise resolveWithResult:Nil];
        return promise;
    }
    
    // Set the status - this prevents a race condition where
    // the message is to set to delivered later
    [message setReadStatus:status forUserID:uid];
    
    [[[self messageReadRef: message] child: uid] setValue:@{bStatus: @(status), bDate: [FIRServerValue timestamp]} withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref ) {
        if (!error) {
            [promise resolveWithResult:Nil];
        }
        else {
            [promise rejectWithReason:error];
        }
    }];
    
    return promise;
}

-(FIRDatabaseReference *) messageReadRef: (id<PMessage>) message {
    return [[[CCMessageWrapper messageWithModel:message] ref] child:bReadPath];
}



@end
