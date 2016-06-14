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

class Socket: NSObject, NSStreamDelegate {
    
    private var inputStream: NSInputStream!
    private var outputStream: NSOutputStream!
    
    var delegate: SocketDelegate?
    
    func connect(host: String, port: UInt32) {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
        inputStream = readStream!.takeRetainedValue() as NSInputStream
        outputStream = writeStream!.takeRetainedValue() as NSOutputStream
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
    }
    
    func sendData(data: NSData) {
        let encodedDataArray = UnsafePointer<UInt8>(data.bytes)
        outputStream.write(encodedDataArray, maxLength: data.length)
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            print("Stream opened")
        case NSStreamEvent.HasBytesAvailable:
            if aStream == inputStream {
                var buffer = [UInt8](count: 4096, repeatedValue: 0)
                while inputStream.hasBytesAvailable {
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if len > 0 {
                        let data = NSData(bytes: &buffer, length: len)
                        
                        print("Server said \(data)")
                        delegate?.receivedData(data)
                    }
                }
            }
        case NSStreamEvent.ErrorOccurred:
            print("Can not connect to the host!")
        case NSStreamEvent.EndEncountered:
            aStream.close()
            aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        default:
            print("Unknown event")
        }
    }
}