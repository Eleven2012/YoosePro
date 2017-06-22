//
//  ShakeManager.m
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ShakeManager.h"
#import "P2PClient.h"
#import "mesg.h"
#import "Constants.h"


@implementation ShakeManager

+ (id)sharedDefault
{
    
    static ShakeManager *manager = nil;
    @synchronized([self class]){
        if(manager==nil){
            DLog(@"Alloc ShakeManager");
            manager = [[ShakeManager alloc] init];
            manager.isSearching = NO;
            manager.searchTime = 5;
        }
    }
    return manager;
}

-(BOOL)search{
    if(self.isSearching){
        return NO;
    }
    
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    if (![socket bindToPort:8899 error:&error])
    {
        //NSLog(@"Error binding: %@", [error localizedDescription]);
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        //NSLog(@"Error receiving: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        //NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        return NO;
    }
    
    self.socket = socket;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int times = self.searchTime;
        self.isSearching = YES;
        while(times>0){
            [self sendUDPBroadcast];
            usleep(1000000);
            times --;
        }
        if(self.socket){
            [self.socket close];
            self.socket = nil;
        }
        self.isSearching = NO;
        if(self.delegate){
            [self.delegate onSearchEnd];
        }
    });
    
    
    return YES;
}

- (void)sendUDPBroadcast
{
    
    NSString *host = @"255.255.255.255";
    int port = 8899;
    
    sMesgShakeType message;
    message.dwCmd = LAN_TRANS_SHAKE_GET;
    message.dwStructSize = 28;
    message.dwStrCon = 0;
    
    Byte sendBuffer[1024];
    memset(sendBuffer, 0, 1024);
    sendBuffer[0] = 1;
    
    NSData *myData = [NSData dataWithBytes:sendBuffer length:1024];
    [self.socket sendData:myData toHost:host port:port withTimeout:-1 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"did send");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"error %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    
    
    NSString *host = nil;
    uint16_t port = 0;
    
    
    
    if (data) {
        Byte receiveBuffer[1024];
        [data getBytes:receiveBuffer length:1024];
        
        if(receiveBuffer[0]==2){
            
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            DLog(@"%@",host);
            int contactId = *(int*)(&receiveBuffer[16]);
            int type = *(int*)(&receiveBuffer[20]);
            int flag = *(int*)(&receiveBuffer[24]);
            DLog(@"%i:%i:%i",contactId,type,flag);
            if(self.delegate){
                
                [self.delegate onReceiveLocalDevice:[NSString stringWithFormat:@"%i",contactId] type:type flag:flag address:host];
            }
        }
        
        
    }
    
}
@end
