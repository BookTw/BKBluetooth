//
//  ViewController.swift
//  Central
//
//  Created by SuPenLi on 2016/8/7.
//  Copyright © 2016年 SuPenLi. All rights reserved.
//

import UIKit
import CoreBluetooth

enum SendDataError: Error {
    case CharacteristicNotFound
}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    // 已經連結上的 peripheral 一定要宣告為整體變數
    var connectPeripheral: CBPeripheral!
    var charDictionary = [String: CBCharacteristic]()
    
    // 已經連結上的 peripher 的 UUID
    var uuid: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let queue = DispatchQueue.global()
        // 將觸發1號method
        centralManager = CBCentralManager(delegate: self, queue: queue)
        
    }
    
    /* 1號method */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 先判斷藍牙是否開啟，如果不是藍牙4.x ，也會傳回電源未開啟
        guard central.state == .poweredOn else {
            // iOS 會出現對話框提醒使用者
            return
        }
        
        // 將觸發 2號 method
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /* 2號method */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("找到藍牙裝置: \(peripheral.name)")
        // 若 peripheral 為另一iOS裝置，這個名字可能會是該裝置的名字
        // BLEDeviceName 為連結裝置名稱
        let BLEDeviceName = ""
        guard peripheral.name == BLEDeviceName else {
            return
        }
        
        central.stopScan()
        
        // 因應重新連線而需要的調整
        uuid = peripheral.identifier
        
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        // 將觸發 3號 method
        central.connect(peripheral, options: nil)
    }
    
    /* 3號method */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 將觸發 4號 method
        // 因應重新連線而需要的調整
        charDictionary = [:]
        
        peripheral.discoverServices(nil)
    }
    
    /* 4號method */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("ERROR: \(#file, #function)")
            return
        }
        
        for service in peripheral.services! {
            // 將觸發 5號 method
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    /* 5號method */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            connectPeripheral.setNotifyValue(true, for: characteristic)
            print(uuidString)
        }
    }
    
    /* 6號method */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //        接受資料
    }
    
    func sendData(data: Data, uuidString: String) throws {
        guard let characteristic = charDictionary[uuidString] else {
            throw SendDataError.CharacteristicNotFound
        }
        connectPeripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )
    }
    
    // 斷線處理
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("連線中斷")
        centralManager.connect(connectPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("藍牙連線失敗")
    }
    
    // 按下要求斷線按鈕
    @IBAction func disconnectButton(_ sender: AnyObject) {
        centralManager.cancelPeripheralConnection(connectPeripheral)
    }
    
    // 按下重新連線按鈕
    @IBAction func reconnectButton(_ sender: AnyObject) {
        centralManager.retrievePeripherals(withIdentifiers: [uuid])
    }
    
    // 訂閱按鈕
    @IBAction func subscribe(_ sender: AnyObject) {
        if let characteristic = charDictionary[uuid.uuidString] {
            connectPeripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    // 取消訂閱按鈕
    @IBAction func unsubscribe(_ sender: AnyObject) {
        if let characteristic = charDictionary[uuid.uuidString] {
            connectPeripheral.setNotifyValue(false, for: characteristic)
        }
    }
    
    // 讀資料按鈕
    @IBAction func readData(_ sender: AnyObject) {
        if let characteristic = charDictionary[uuid.uuidString] {
            
            connectPeripheral.readValue(for: characteristic)
            
        } else {
            print("找不到CC03")
        }
    }
    
    // 寫資料按鈕
    @IBAction func writeData(_ sender: AnyObject) {
        
        let str = "寫入資料"
        
        func dataWithHexString(hex: String) -> Data {
            var hex = hex
            var data = Data()
            while(hex.count > 0) {
                let subIndex = hex.index(hex.startIndex, offsetBy: 2)
                let c = String(hex[..<subIndex])
                hex = String(hex[subIndex...])
                var ch: UInt32 = 0
                Scanner(string: c).scanHexInt32(&ch)
                var char = UInt8(ch)
                data.append(&char, count: 1)
            }
            return data
        }
        let data = dataWithHexString(hex: str)
        print(data.base64EncodedString())
        do {
            try sendData(data: data, uuidString: uuid.uuidString)
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

