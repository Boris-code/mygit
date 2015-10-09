//
//  CentralController.h
//  CoreBluetooth
//
//  Created by LIUBO on 15/9/30.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface CentralController: UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(nonatomic,strong) NSString* characteristicUUID;

-(void) getAroundBLE;
-(void) connectBLE:(CBPeripheral *)peripheral;  //BLE  Bluetooth Low Energy
-(void) closeConnect;
-(void) sendMessage:(NSData*) data;

-(void) handleMessage:(NSData*) data;
-(void) didDiscoverPeripheral:(CBPeripheral *)peripheral;//搜索到一次外设 调用一次
-(void) setCharacteristicUUID:(NSString* ) characteristicUUID;//设置想要监听的 特征的UUID

@end
