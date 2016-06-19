//
//  Socket.swift
//  ChatClient
//
//  Created by Kevin Greer on 6/12/16.
//  Copyright © 2016 KevinGreer. All rights reserved.
//

import Foundation

protocol SocketDelegate {
    func receivedData(data: NSData)
}

/**
 To open a socket to an address such as "localhost:8080", just create a socket
 object: `Socket("localhost", port: 8080)`.
 
 To send data: socket.sendData(data)
 
 To receive data: Have the class that responds to the data implement the
 SocketDelegate protocol. The argument of `receiveData` is the data that has
 been read from the socket.
 */
class Socket: NSObject, NSStreamDelegate {
    
    private var inputStream: NSInputStream?
    private var outputStream: NSOutputStream?
    
    var delegate: SocketDelegate?
    
    convenience init(host: String, port: Int) {
        self.init()
        connect(host, port: port)
    }
    
    func connect(host: String, port: Int) {
        NSStream.getStreamsToHostWithName(host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        if inputStream != nil && outputStream != nil {
            inputStream!.delegate = self
            outputStream!.delegate = self
            
            inputStream!.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream!.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            inputStream!.open()
            outputStream!.open()
        } else {
            print("Unable to create streams")
        }
    }
    
    func sendData(data: NSData) {
        let encodedDataArray = UnsafePointer<UInt8>(data.bytes)
        outputStream?.write(encodedDataArray, maxLength: data.length)
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            print("Stream opened")
        case NSStreamEvent.HasBytesAvailable:
            if aStream == inputStream {
                var buffer = [UInt8](count: 4096, repeatedValue: 0)
                while inputStream!.hasBytesAvailable {
                    let len = inputStream!.read(&buffer, maxLength: buffer.count)
                    if len > 0 {
                        let data = NSData(bytes: &buffer, length: len)
                        
                        print("Received data from server")
                        delegate?.receivedData(data)
                    }
                }
            }
        case NSStreamEvent.HasSpaceAvailable:
            print("Stream has space")
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred: \(aStream.streamError?.description)")
        case NSStreamEvent.EndEncountered:
            aStream.close()
            aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        default:
            print("Unknown event")
        }
    }
}