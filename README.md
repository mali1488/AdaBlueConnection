# AdaBlueConnection
This is a simple little class for handling the Adafruit Bluefruit nRF8001 bluetooth device.
I found it hard to find a simple tutorial or example on how to easy connect to the device with swift 2 so I made
this class. A lot of code comes from this bigger project: https://github.com/adafruit/Bluefruit_LE_Connect

Its is compatible with xcode 7.0 beta and swift 2.0.

# How to use
Initialize it with no arguments. Then it searchs for a device named "UART" 
```
var AdaBluetoothController = AdaBlueConnection()

```
Initialize it with a string argument to search for a specific name device. 
 
```
// In Arduino editor
BTLEserial.setDeviceName("myName")

// In xcode
var AdaBluetoothController = AdaBlueConnection("myName")
```

