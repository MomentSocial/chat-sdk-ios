//
//  PInvoiceMessageHandler.h
//  Pods
//
//  Created by Saleh AlDhobaie on 24/04/2019.
//

#ifndef PInvoiceMessageHandler_h
#define PInvoiceMessageHandler_h

#import <ChatSDK/PMessageHandler.h>


@class RXPromise;

@protocol PInvoiceMessageHandler <PMessageHandler>

/**
 * @brief Send an invoice message
 */
-(RXPromise *) sendMessageWithInvoice:(NSString *)service amount:(NSString *)amount withThreadEntityID:(NSString *)threadID;

@end


#endif /* PInvoiceMessageHandler_h */
