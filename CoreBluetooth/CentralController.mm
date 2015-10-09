//
//  CentralController.m
//  CoreBluetooth
//
//  Created by LIUBO on 15/9/30.
//
//

#import "CentralController.h"
#import "SVProgressHUD.h"
#import <vector>

std::vector<NSString *> peripheralIds;

@interface CentralController()

@property(nonatomic,strong)CBCentralManager *manager;
@property(nonatomic,strong)CBPeripheral *peripheral;
@property(nonatomic,strong)CBCharacteristic * characteristic;

@end


@implementation CentralController

@synthesize  characteristicUUID;

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---------------------接口相关------------------------------
-(void) getAroundBLE{
    peripheralIds.clear();
    //初始化后调用  centralManagerDidUpdateState
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

-(void) connectBLE:(CBPeripheral *)peripheral{
    if (peripheral!=nil) {
        [_manager stopScan];//停止扫描外设
        [_manager connectPeripheral:peripheral options:nil];//连接外设
        _peripheral=peripheral;
    }
}

-(void) closeConnect{
    if (_peripheral != nil)
    {
        [_manager cancelPeripheralConnection:_peripheral];
    }


}

-(void) sendMessage:(NSData *) data{
    if (_peripheral!=nil) {
        [_peripheral writeValue:data forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(void) handleMessage:(NSData*) data{
    //TODO  处理接受到的信息
}

-(void) didDiscoverPeripheral:(CBPeripheral *)peripheral{
    //TODO 处理搜索到的蓝牙
}
//---------------------------------------------------

#pragma  mark -- CBCentralManagerDelegate
//1 检测蓝牙设备状态 在初始化CBCentralManager的时候会打开设备，只有当设备正确打开后才能使用
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"检测蓝牙状态");
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];

            NSLog(@"CBCentralManagerStatePoweredOn");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;

        default:
            NSLog(@"CM did Change State");

            break;
    }
}

//2 扫描到设备会进入方法  RSSI信号强度
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)args_peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    //排除扫描到的重复的外设
    for(int i=0;i<peripheralIds.size();++i){
        NSString* peripheralId=peripheralIds.at(i);
        if ([[args_peripheral.identifier UUIDString] isEqual:peripheralId]) {
            return ;
        }
    }

    peripheralIds.push_back([args_peripheral.identifier UUIDString]);
    [self didDiscoverPeripheral:args_peripheral];

}

//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Connecting Fail: %@",error);

    [SVProgressHUD showErrorWithStatus:@"连接失败"];
//    [_manager connectPeripheral:self.peripheral options:nil];//继续连接

}

//3 连接到Peripherals-成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)args_peripheral{
    [SVProgressHUD showSuccessWithStatus:@"蓝牙已连接"];

    NSLog(@"Connected");

    [args_peripheral setDelegate:self];
    [args_peripheral discoverServices:nil];
    NSLog(@"Start Discover Service!!!");

}

//Peripherals断开连接 断开连接后调用（代理）
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"蓝牙已断开");
    [SVProgressHUD showSuccessWithStatus:@"蓝牙已断开"];
    peripheralIds.clear();
}

//4 扫描到Services
-(void)peripheral:(CBPeripheral *)args_peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"didDiscoverServices");
    if (error) {
        NSLog(@"Error discover service: %@",[error localizedDescription]);
        return;
    }

    for(CBService *service in args_peripheral.services){
        NSLog(@"Service found with UUID: %@",service);

        //扫描每个service的Characteristics
        [args_peripheral discoverCharacteristics:nil forService:service];


    }

}

//5 扫描到Characteristics
-(void)peripheral:(CBPeripheral *)args_peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{

    if (error) {
        NSLog(@"Error discover Character");
        return;
    }

    for (CBCharacteristic *character in service.characteristics) {

        NSLog(@"Characteristic FOUND: %@",character.UUID);

        if ([character.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID]]) {//选择要监听的特征值

            NSLog(@"Successfully Found the Character I wanted!!!");
            _characteristic=character;

            [args_peripheral setNotifyValue:YES forCharacteristic:character];//6 订阅感兴趣的特性的值
        }
    }

}

//获取的charateristic的值  即传过来的数据（NSData * 类型）
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }

    NSData * data=characteristic.value; //接受到数据

    [self handleMessage:data];
}





@end
