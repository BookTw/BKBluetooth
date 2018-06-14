# DBCoreML

[![CI Status](https://img.shields.io/travis/dabechien/DBCoreML.svg?style=flat)](https://travis-ci.org/dabechien/DBCoreML)
[![License](https://img.shields.io/cocoapods/l/DBCoreML.svg?style=flat)](https://cocoapods.org/pods/DBCoreML)
[![Platform](https://img.shields.io/cocoapods/p/DBCoreML.svg?style=flat)](https://cocoapods.org/pods/DBCoreML)


## Requirements
XCode 9.0 
iOS 10 ++
## Installation
add following file to your project.

## Useage
Start the BLEManger
```swift
let queue = DispatchQueue.global()
centralManager = CBCentralManager(delegate: self, queue: queue)
```
Send Data
```swift
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
```
Disconnect
```swift
	centralManager.cancelPeripheralConnection(connectPeripheral)
```
Reconnect
```swift
centralManager.retrievePeripherals(withIdentifiers: [uuid])
```

Subscribe
```swift
if let characteristic = charDictionary[uuid.uuidString] {
            connectPeripheral.setNotifyValue(true, for: characteristic)
}
```
Unsubscribe
```swift
if let characteristic = charDictionary[uuid.uuidString] {
            connectPeripheral.setNotifyValue(false, for: characteristic)
        }
```
ReadData
```swift
 if let characteristic = charDictionary[uuid.uuidString] {
            connectPeripheral.readValue(for: characteristic)
} 
```
## Author

BookTw, marco060318@gmail.com
