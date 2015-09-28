//  Created by Mattias on 2015-09-03.
//  Copyright (c) 2015 Mattias. All rights reserved.

import Foundation
import CoreBluetooth
import UIKit

class AdaBlueConnection: NSObject, CBCentralManagerDelegate ,CBPeripheralDelegate{
    var centralManager:CBCentralManager!
    var blueToothReady = false
    var connected = false
    var currentPeripheral:CBPeripheral!
    var contrinueCalibration = true

    var rxCharacteristic:CBCharacteristic?
    var txCharacteristic:CBCharacteristic?
    
    override init(){
        super.init()
        self.startUpCentralManager()
    }
    
    init(name : String){
        self.customName = name
        super.init()
        self.startUpCentralManager()
    }
    
    func startUpCentralManager() {
        print("Initializing central manager")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func discoverDevices() {
        print("discovering devices")
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("found something \(peripheral.name)")
        if ((peripheral.name == "UART") || (peripheral.name == self.customName)) {
            print("found device adafruit, name: \(peripheral.name), trying to connect")
            peripheral.delegate = self;
            self.currentPeripheral = peripheral
            centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("disconnet from \(peripheral.name), error: \(error.debugDescription)")
        self.connected = false
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("Restore state")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.connected = true
        peripheral.delegate = self;
        peripheral.discoverServices(nil)
        print("connected successfully to \(peripheral.name)")
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to Peripheral \(peripheral.name), error: \(error.debugDescription)")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("checking state")
        switch (central.state) {
            case .PoweredOff:
                print("CoreBluetooth BLE hardware is powered off")
                break
            case .PoweredOn:
                print("CoreBluetooth BLE hardware is powered on and ready")
                blueToothReady = true;
                break
            case .Resetting:
                print("CoreBluetooth BLE hardware is resetting")
                break
            case .Unauthorized:
                print("CoreBluetooth BLE state is unauthorized")
                break
            case .Unknown:
                print("CoreBluetooth BLE state is unknown")
                break
            case .Unsupported:
                print("CoreBluetooth BLE hardware is unsupported on this platform");
                break
        }
        if blueToothReady {
            discoverDevices()
        }
    }
    
    func checkConnection() -> Bool {
        print("check connection")
        if (self.connected) {
            print("connected to \(self.currentPeripheral.name)")
            return true
        } else {
            print("disconnected, try connecting again")
            return false
        }
    }
    
    func connect() {
        discoverDevices()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("did discover servies peripheral")
        if error != nil {
            print("didDiscoverServices", "\(error.debugDescription)")
        }
        print("no error in services peripheral")
         for service in peripheral.services! {
            // Service characteristics already discovered
            if (service.characteristics != nil){
                // If characteristics have already been discovered, do not check again
                self.peripheral(peripheral, didDiscoverCharacteristicsForService: service, error: nil)
            }
            //self.uartService = service
            peripheral.discoverCharacteristics(nil, forService: service)            
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil {
            print("didDiscoverCharacteristicsForService, error: \(error.debugDescription)")
            return
        }
        print("---- charac serrvice ----")
        for c in service.characteristics ?? [] {
            print("service charac found")
            switch c.UUID {
            case CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e"): //txCharacteristicUUID
                print("didDiscoverCharacteristicsForService \(service.description) : TX")
                self.currentPeripheral.setNotifyValue(true, forCharacteristic: c)
                self.txCharacteristic = c
                break
            case CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e"): //rxCharacteristicUUID
                print("didDiscoverCharacteristicsForService \(service.description) : RX")
                self.currentPeripheral.setNotifyValue(true, forCharacteristic: c)
                self.rxCharacteristic = c
                break
            default:
                print("no uuid match")
                break
            }
        }
    }
    
    func readValueForCharacteristic(_ characteristic: CBCharacteristic) {
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("read value")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("include service");
    }
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("didmodifyservice")
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        print("updated rssi")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        // This is where data is received when sent from other peripheral BLE device
        var dataString = NSString(data: characteristic.value!, encoding:NSUTF8StringEncoding)
        print(dataString!)
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didUpdateNotificationStateForCharacteristic")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didWriteValueForCharacteristic")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("didWriteValueForDescriptor")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("didDiscoverDescriptorsForCharacteristic")
    }
    
    func writeString(string:NSString) -> Bool {
        let data = NSData(bytes: string.UTF8String, length: string.length)
        print("sending data: \(string), to: \(self.currentPeripheral.name)")
        return writeRawData(data)
    }
    
    func writeRawData(data:NSData) -> Bool {
        //Send data to peripheral
        
        if (txCharacteristic == nil){
            print("writeRawData, Unable to write data without txcharacteristic")
            return false
        }
        
        var writeType:CBCharacteristicWriteType
        
        if (txCharacteristic!.properties.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue) != 0 {
            writeType = CBCharacteristicWriteType.WithoutResponse
        } else if ((txCharacteristic!.properties.rawValue & CBCharacteristicProperties.Write.rawValue) != 0){
            writeType = CBCharacteristicWriteType.WithResponse
        } else{
            print("writeRawData, Unable to write data without characteristic write property")
            return false
        }
        
        //send data in lengths of <= 20 bytes
        let dataLength = data.length
        let limit = 20
        // Data length ok, send data
        if dataLength <= limit {
            currentPeripheral.writeValue(data, forCharacteristic: txCharacteristic!, type: writeType)
        } else {
            // Too much data, send in smaller packets
            var lengthToSend = limit
            var sentData = 0
            while sentData < dataLength {
                
                let remainder = dataLength - sentData
                if remainder <= lengthToSend {
                    lengthToSend = remainder
                }
                
                let range = NSMakeRange(sentData, lengthToSend)
                var newBytes = [UInt8](count: lengthToSend, repeatedValue: 0)
                data.getBytes(&newBytes, range: range)
                let newData = NSData(bytes: newBytes, length: lengthToSend)
                self.currentPeripheral.writeValue(newData, forCharacteristic: self.txCharacteristic!, type: writeType)
                
                sentData += lengthToSend
            }
        }
        return true
    }
}