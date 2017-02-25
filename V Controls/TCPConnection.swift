//
//  TCPConnection.swift
//  V Controls
//
//  Created by George Koepplinger on 2/20/15.
//  Copyright (c) 2015 George Koepplinger. All rights reserved.
//

import Foundation


class TCPConnection : NSObject
{
    var bsocket  : GCDAsyncSocket?
    var error    : NSError?
    var hostIP   : String
    var portID   : UInt16
    var rxBufr   : Data?

    init(hostIP: String, portID: UInt16)
    {
        self.hostIP = hostIP
        self.portID = portID
        bsocket     == nil
        rxBufr      == nil
    }
    
    func connected () -> Bool
    {
        if (bsocket == nil)
        {
            print("no connection")
            return false
        }
        else
        {
            return bsocket!.isConnected
        }
    }
    
    func connect ()
    {
        if (!connected())
        {
            bsocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            do {
                try bsocket!.connect(toHost: hostIP, onPort: portID, withTimeout: 1.0)
            } catch let error1 as NSError {
                error = error1
            }
        }
    }
    
    func delay (_ delay: Double, closure:@escaping ()->())
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay*Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func read () -> Bool
    {
        if (connected())
        {
            bsocket!.readData(withTimeout: -1.0, tag: 0) // async read request
            return true
        }

        return false
    }
    
    func write (_ data: Data) -> Bool
    {
        if (connected())
        {
            bsocket!.write(data, withTimeout: -1.0, tag: 0)
            return true
        }
        else
        {
            return false
        }
    }
    
    func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        print("connected to \(host) on port \(p)")
    }
   
    
    func socket(_ socket : GCDAsyncSocket, didWriteDataWithTag tag:UInt16)
    {
        print("write completed")
    }
    
    func socket(_ socket : GCDAsyncSocket, didReadData data:Data, withTag tag:UInt16)
    {
        rxBufr  = data
        print("read completed: \(NSString(data: rxBufr!, encoding: String.Encoding.utf8.rawValue)!)")
    }

}



