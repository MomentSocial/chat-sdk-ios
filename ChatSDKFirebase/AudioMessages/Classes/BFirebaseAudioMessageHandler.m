//
//  BFirebaseVideoMessageHandler.m
//  Pods
//
//  Created by Benjamin Smiley-andrews on 13/11/2016.
//
//

#import "BFirebaseAudioMessageHandler.h"

#import <ChatSDK/Core.h>
#import "BAudioMessageCell.h"

@implementation BFirebaseAudioMessageHandler

-(RXPromise *) sendMessageWithAudio:(NSData *) data duration:(double) seconds withThreadEntityID:(NSString *)threadID {
    // Set the URLs for the images and save it in CoreData
    [[BStorageManager sharedManager].a beginUndoGroup];
    
    id<PMessage> message = [[BStorageManager sharedManager].a createEntity:bMessageEntity];
    
    message.type = @(bMessageTypeAudio);
    [message setTextAsDictionary:@{bMessageTextKey: bNullString}];
    
    id<PThread> thread = [[BStorageManager sharedManager].a fetchEntityWithID:threadID withType:bThreadEntity];
    [thread addMessage: message];

    message.date = [NSDate date];
    message.userModel = NM.currentUser;
    message.delivered = @NO;
    message.read = @YES;
    message.flagged = @NO;
    
    return [self uploadAudioWithData:data].thenOnMain(^id(NSDictionary * urls) {
        
        NSString * audioURL = urls[bAudioPath];
        NSString * messageText = [NSString stringWithFormat:@"%@,%f", audioURL, seconds];
        [message setTextAsDictionary:@{bMessageTextKey: messageText,
                                       bMessageAudioURL: audioURL,
                                       bMessageAudioLength: @(seconds)}];        
        
        return [NM.core sendMessage:message];
    }, Nil);
}

- (RXPromise *)uploadAudioWithData: (NSData *) data {
    
    // Upload the images:
    return [NM.upload uploadFile:data withName:@"audio.mp4" mimeType:@"audio/mp4"].thenOnMain(^id(NSDictionary * result) {
        
        NSMutableDictionary * urls = [NSMutableDictionary new];
        urls[bAudioPath] = result[bFilePath];
        
        return urls;
    }, Nil);
}

-(Class) messageCellClass {
    return [BAudioMessageCell class];
}

@end
