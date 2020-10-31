//
//  PrinterBLE.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 13/06/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import UIKit
import CoreBluetooth

class PrinterBLEController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var deviceView: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var messageView: UILabel!
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    var txCharacteristic:CBCharacteristic!
    
    let BEAN_NAME = "BlueTooth Printer"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityView.startAnimating()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func printReceipt(id: Int32) {
        
        let helloWorld = "Hello World! - \(id)".data(using: String.Encoding.utf8)
        
        var value : [UInt8] = [0x1b, 0x21, 0x00]
        value[2] |= 0x10
        var data = NSData(bytes: value, length: value.count)
        peripheral.writeValue(data as Data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        peripheral.writeValue(helloWorld!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        value[2] &= 0xEF
        data = NSData(bytes: value, length: value.count)
        peripheral.writeValue(data as Data, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        peripheral.writeValue(helloWorld!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        
        activityView.stopAnimating()
        activityView.isHidden = true
    }

    // MARK: CBCentralManagerDelegate Methods
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(BEAN_NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
            
            messageView.text = "Discovered \(BEAN_NAME)"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        deviceView.text = "Connected to \(BEAN_NAME)"
        peripheral.discoverServices(nil)
        
        guard let services = peripheral.services else {
            activityView.stopAnimating()
            messageView.text = "No characteristics for \(BEAN_NAME)"
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case CBManagerState.poweredOff:
            messageView.text = "Bluetooth: PoweredOff"
        case CBManagerState.unauthorized:
            messageView.text = "Bluetooth: Unauthorized"
            break
        case CBManagerState.unknown:
            messageView.text = "Bluetooth: Unknown"
            break
        case CBManagerState.poweredOn:
            messageView.text = "Bluetooth: PoweredOn"
            manager.scanForPeripherals(withServices: nil, options: nil)
            return
        case CBManagerState.resetting:
            messageView.text = "Bluetooth: Resetting"
            break
        case CBManagerState.unsupported:
            messageView.text = "Bluetooth: Unsupported"
            break
        default:
            messageView.text = ""
            break
        }
        activityView.stopAnimating()
    }
    
    // MARK: CBPeripheralDelegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            txCharacteristic = characteristic
            print(characteristic.descriptors!.first.debugDescription)
            printReceipt(id: 0)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Sent")
    }
}
