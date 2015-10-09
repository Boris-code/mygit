//
//  PeripheralController.m
//  CoreBluetooth
//
//  Created by LIUBO on 15/9/30.
//
//

#import "PeripheralController.h"
#import "SVProgressHUD.h"

static NSString * const kServiceUUID = @"52622A67-6EA2-43CC-9B00-E35AFC91596C";
static NSString * const kCharacteristicUUID = @"4D381672-ED4D-4049-B383-957082E5DB9C";

@interface PeripheralController()

@property(nonatomic,strong)CBPeripheralManager *manager;
@property(nonatomic,strong)CBMutableCharacteristic *customCharacteristic;
@property(nonatomic,strong)CBMutableService *customService;

@end


@implementation PeripheralController


- (void)viewDidLoad{
    [super viewDidLoad];

    _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil]; //1 启动一个Peripheral管理对象

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning]; // Dispose of any resources that can be recreated.
}

#pragma  mark -- CBPeripheralManagerDelegate

//2 peripheralManager状态改变
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            NSLog(@"CBPeripheralManagerStatePoweredOn");

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
            NSLog(@"PM did change state");
            break;
    }

}

//3 配置bluetooch的  (可能需要重写)
-(void)setupService{

    CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];

    _customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];

    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];

    _customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];//上例中primary参数传递的是YES，表示这是一个主服务，即描述了一个设备的主要功能且能被其它服务引用
    [_customService setCharacteristics:@[_customCharacteristic]];

    [_manager addService:_customService];
    NSLog(@"Adding Service!!");

}

//4 [manager addService:customService] 后调用
//perihpheral添加了service
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error){
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
    }
    if (error == nil) {
        //发送广播 startAdvertising:的参数是一个字典，Peripheral管理器支持且仅支持两个key值：CBAdvertisementDataLocalNameKey与CBAdvertisementDataServiceUUIDsKey。这两个值描述了数据的详情
        [_manager startAdvertising:@{CBAdvertisementDataLocalNameKey: @"ICServer",CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:kServiceUUID]]}];
        NSLog(@"Service Added Successfully !!!");
    }

}

//5
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"Start Advertising");

    if (error){
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}

//写characteristics请求 (接收到central 发来数据)
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest *request = requests[0];

    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        [self handleMessage:request.value];

        [_manager respondToRequest:request withResult:CBATTErrorSuccess];// 对请求作出成功响应
    }else{
        [_manager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }


}


#pragma mark - 检测蓝牙连接状态

//订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{

    [SVProgressHUD showSuccessWithStatus:@"蓝牙已连接"];

}

//取消订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    [SVProgressHUD showErrorWithStatus:@"连接断开"];
    NSLog(@"连接断开");
}


#pragma mark - click

-(void) sendMessage:(NSData*) data{

    // 最后一个参数指定我们想将修改发送给哪个Central端，如果传nil，则会发送给所有连接的Central
    [self.manager updateValue:data forCharacteristic:_customCharacteristic onSubscribedCentrals:nil];
    
}

-(void) handleMessage:(NSData*) data{
    //TODO
}

@end
