//
//  GlobalThread.m
//  Yoosee
//
//  Created by guojunyi on 14-4-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "GlobalThread.h"
#import "Constants.h"
#import "FListManager.h"
#import "Contact.h"
#import "P2PClient.h"
#import "ShakeManager.h"
@implementation GlobalThread
static int initCount;
+ (id)sharedThread:(BOOL)isRelease
{
    
    static GlobalThread *manager = nil;
    
    @synchronized([self class]){
        if(isRelease){
            DLog(@"Release GlobalThread");
            manager = nil;
        }else{
            if(manager==nil){
                DLog(@"Alloc GlobalThread");
                initCount = 3;
                manager = [[GlobalThread alloc] init];
                manager.isRun = NO;
            }
        }
        
    }
    return manager;
}

-(void)start{
    if(!self.isRun){
        self.isRun = !self.isRun;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            while(initCount>0){
                initCount --;
                NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
                NSArray *contacts = [[FListManager sharedFList] getContacts];
                for(int i=0;i<[contacts count];i++){
                    
                    Contact *contact = [contacts objectAtIndex:i];
                    [contactIds addObject:contact.contactId];
                }
                [[P2PClient sharedClient] getContactsStates:contactIds];
                sleep(1.0);
            }
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while(self.isRun){
                    if(!self.isPause){
                        DLog(@"Thread getContactsStatus");
                        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
                        NSArray *contacts = [[FListManager sharedFList] getContacts];
                        for(int i=0;i<[contacts count];i++){
                            
                            Contact *contact = [contacts objectAtIndex:i];
                            [contactIds addObject:contact.contactId];
                        }
                        [[P2PClient sharedClient] getContactsStates:contactIds];
                        [[FListManager sharedFList] getDefenceStates];
                        [[FListManager sharedFList] searchLocalDevices];
                        usleep(60*1000000);
                    }else{
                        sleep(1.0);
                    }
                    
                }
                
            });
            
            
        });
        
        
        
    }
}

-(void)kill{
    self.isRun = NO;
    [GlobalThread sharedThread:YES];
}
@end
