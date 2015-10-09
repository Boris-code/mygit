//
//  PeripheralController.h
//  CoreBluetooth
//
//  Created by LIUBO on 15/9/30.
//  Copyright © 2015年 liubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface PeripheralController : UIViewController<CBPeripheralManagerDelegate>

-(void) sendMessage:(NSData*) data;
-(void) handleMessage:(NSData*) data;

@end
