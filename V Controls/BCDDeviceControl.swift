//
//  BCDDeviceControl.swift
//  V Controls
//
//  Created by George Koepplinger on 2/25/15.
//  Copyright (c) 2015 George Koepplinger. All rights reserved.
//

import Foundation

protocol xxx
{
    func yyy()
    
}

class BCDDeviceControl : NSObject
{
    enum responseTypes {case eos, change, status}
    
    struct responseStruct
    {
        var type     : responseTypes
        var response : String
        var remaining: String
    }
    
    var device   : String
    var inChans  : Int
    var outChans : Int
    var lsocket  : GCDAsyncSocket?
    var error    : NSError?
    var hostIP   : String
    var portID   : UInt16
    var routes   = [Int]()
    var volumes  = [Float]() // db
    var mutes    = [Bool]()
  
    init(device: String, inChans: Int, outChans: Int, hostIP: String, portID: UInt16)
    {
        self.device   = device
        self.inChans  = inChans
        self.outChans = outChans
        self.hostIP   = hostIP
        self.portID   = portID
        lsocket       == nil
        
        for _  in 1...outChans
        {
            routes.append(0)
            volumes.append(-70.0)
            mutes.append(false)
        }
    }
    
    func connect ()
    {
        if (!connected())
        {
            
 //           * [asyncSocket setDelegate:nil];
 //           * [asyncSocket disconnect];
 //           * [asyncSocket setDelegate:self];
//            * [asyncSocket connect...];
            
            lsocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
 do {
     try lsocket!.connect(toHost: hostIP, onPort: portID, withTimeout: 1.0)
 } catch let error1 as NSError {
     error = error1
 }
        }
    }
    
    func connected () -> Bool
    {
        if (lsocket == nil)
        {
 //           println("\(device): not connected")
            return false
        }
        else
        {
//            println("\(device): connected = \(lsocket!.isConnected)")
            return lsocket!.isConnected
        }
    }
    
    func read () -> Bool
    {
        if (connected())
        {
            lsocket!.readData(withTimeout: -1.0, tag: 0) // async read request
            return true
        }
        
        return false
    }
    
    func sendCommand (_ command: String) -> Bool
    {
        if (connected())
        {
            lsocket!.write(command.data(using: String.Encoding.utf8)!, withTimeout: -1.0, tag: 0)
            
            read () // to invoke async receive
    //        println("sendCommand: \(command)")
            return true
        }
        else
        {
            return false
        }
    }
    
    func setRoute (_ inChan: Int, outChan: Int) -> Bool
    {
        return sendCommand ("CL0I\(inChan)O\(outChan)T")
    }
    
    func setMute (_ mute: Bool, outChan: Int) -> Bool
    {
        if (mute)
        {
            return sendCommand ("CL0O\(outChan)VMT")
        }
        else
        {
            return sendCommand ("CL0O\(outChan)VUT")
        }
    }
    
    func setVolume (_ vol: Float, outChan: Int) -> Bool
    {
        return sendCommand ("CL0O\(outChan)VA\(Int(vol*10.0))T")
    }
    
    func getRoutes ()-> Bool
    {
        var result: Bool = false
        
        for i in 1...outChans
        {
            result = sendCommand("SL0O\(i)T")
        }
    
        return result
    }
    
    func getVolumes ()-> Bool
    {
        var result: Bool = false
        
        for i in 1...outChans
        {
            result = sendCommand("SL0O\(i)VT")
        }
        
        return result
    }
    
    func nextResponse(_ str: String) -> responseStruct
    {
        var resp = responseStruct (type: .eos, response: "", remaining: "")
        var curInx  : Int = 0
        var respInx : Int = 0
        var respOK  : Bool = false
        
        for char in str.characters
        {
            switch char
            {
                case "C": // change route
                    resp.type = .change
                    respInx   = curInx
                
                case "S": // route status
                    resp.type = .status
                    respInx   = curInx
                
                case "T": // change route closure
                    if (resp.type == .change)
                    {
                        respOK = true
                    }
                
                case ")": // route status closure
                    if (resp.type == .status)
                    {
                        respOK = true
                    }
                
            default:
                respOK = false
            }
            curInx += 1
            if (respOK)
            {
                break
            }
        }
        
        if (respOK)
        {
            resp.response = str.substring(with: (str.characters.index(str.startIndex, offsetBy: respInx) ..< str.characters.index(str.endIndex, offsetBy: curInx-str.characters.count)))
            resp.remaining = str.substring(from: str.characters.index(str.startIndex, offsetBy: curInx))
        }
        else
        {
            resp.type = .eos
        }
        
        return resp
    }
    
    func slice (_ str: String, startInx: Int, endInx: Int) -> String
    {
        if ((startInx <= endInx) && (endInx <= str.characters.count))
        {
            let rng = (str.characters.index(str.startIndex, offsetBy: startInx) ..< str.characters.index(str.startIndex, offsetBy: endInx))
        
            return str.substring(with: rng)
        }
        else
        {
            return ""
        }
    }
    
    func toInt (_ str: String, offset: inout Int) -> Int?
    {
        let substr = str.substring(from: str.characters.index(str.startIndex, offsetBy: offset))
        
        var curInx   : Int = 0
        var startInx : Int = 0
        var endInx   : Int = 0
        var started  : Bool = false
        var finished : Bool = false
    
        for char in substr.characters
        {
            switch char
            {
                case "-":
                    if (!started)
                    {
                        started = true
                        startInx = curInx
                    }
                    else
                    {
                        finished = true
                        endInx   = curInx
                    }
   
                case "0","1","2","3","4","5","6","7","8","9":
                
                    if (!started)
                    {
                        started = true
                        startInx = curInx
                    }
                
                default:
                    if (started)
                    {
                        finished = true
                        endInx   = curInx
                }
            }
            curInx += 1
            if (finished)
            {
                break
            }
        }
        
        if (finished)
        {
            let rng = (substr.characters.index(substr.startIndex, offsetBy: startInx) ..< substr.characters.index(substr.startIndex, offsetBy: endInx))
            
            let intStr = substr.substring(with: rng)
            
            offset += endInx
            
            return Int(intStr)
        }
        else
        {
            return nil
        }
    }
    
    func updateSwitchRoute (_ inChan: Int?, outChan: Int?)
    {
        if ((inChan != nil) && (outChan != nil))
        {
            if ((inChan! <= inChans) && (outChan! <= outChans))
            {
                routes[outChan!-1] = inChan!-1
            }
        }
    }
    
    func updateVolume (_ sfx: String, vol: Int?, outChan: Int?)
    {
        if ((outChan != nil) && (outChan! <= outChans))
        {

            if (vol != nil)
            {
                if ((vol! >= -700) && (vol! <= 100))
                {
                    volumes[outChan!-1] = Float(vol!) / 10.0
                    mutes[outChan!-1]   = false
                }
            }
            else
            {
                switch sfx
                {
                case "VMT","M )":
                    
                    mutes[outChan!-1] = true
                    
                case "VUT":
                    
                    mutes[outChan!-1] = false
                    
                default:
                    break
                }
            }
        }
    }
    
    func updateChange (_ changeResp: String)
    {
        //
        // BCD response syntax:
        //
        //  CL0I#O#T   - switch route change
        //  CL0O#VA#T  - out volume change
        //  CL0O#VMT   - out volume mute
        //  CL0O#VUT   - out volume unmute
        //
        
        var inChan : Int?
        var outChan: Int?
        var outVol : Int?
        var offset : Int
        var respSfx: String
        
        switch changeResp[changeResp.characters.index(changeResp.startIndex, offsetBy: 3)]
        {
            case "I":   // routing change
  //              println("routing change")
                offset  = 4
                inChan  = toInt(changeResp, offset: &offset)
                outChan = toInt(changeResp, offset: &offset)
                updateSwitchRoute(inChan, outChan: outChan)

            
            case "O":   // volume change
    //            println("volume change")
                offset  = 4
                outChan = toInt(changeResp, offset: &offset)
                outVol  = toInt(changeResp, offset: &offset)
                respSfx = changeResp.substring(from: changeResp.characters.index(changeResp.endIndex, offsetBy: -3))
                updateVolume (respSfx, vol: outVol, outChan: outChan)
            
           default:
             break
        }
    }
    
    func updateStatus (_ statusResp: String)
    {
        //
        // BCD response syntax:
        //
        //  SL0O#T( # )  - output -> input switch route
        //  SL0O#VT( # ) - unmuted volume level [-700..100]
        //  SL0O#VT( M ) - volume muted
        //
        
        var inChan : Int?
        var outChan: Int?
        var outVol : Int?
        var offset : Int
        var respSfx: String
        
        switch statusResp[statusResp.characters.index(statusResp.startIndex, offsetBy: 5)]
        {
        case "T":   // switch route
   //         println("route status")
            offset  = 4
            outChan = toInt(statusResp, offset: &offset)
            inChan  = toInt(statusResp, offset: &offset)
            updateSwitchRoute(inChan, outChan: outChan)
            
        case "V":   // volume level
  //          println("volume status")
            offset  = 4
            outChan = toInt(statusResp, offset: &offset)
            outVol  = toInt(statusResp, offset: &offset)
            respSfx = statusResp.substring(from: statusResp.characters.index(statusResp.endIndex, offsetBy: -3))
            updateVolume (respSfx, vol: outVol, outChan: outChan)
            
            
        default:
            break
        }
    }
    
    func processResponse(_ response: String)
    {
        var str  : String = response
        var resp : responseStruct
       repeat
        {
            resp = nextResponse(str)
    
            switch resp.type
            {
                case .change: // end of string
                    updateChange (resp.response)
            
                case .status: // change route
                    updateStatus (resp.response)
                
                default:      // no more responses
                    break
                
            }
            str = resp.remaining
        } while (resp.type != .eos)
    }
    
    func socket(_ socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        
  //      println("\(device): connected to \(host) on port \(p)")
    }
    
    
    func socket(_ socket : GCDAsyncSocket, didWriteDataWithTag tag:UInt16)
    {
  //      println("\(device): command sent")
    }
    
    func socket(_ socket : GCDAsyncSocket, didReadData data:Data, withTag tag:UInt16)
    {
  //      println("\(device): response rcvd \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
        processResponse (NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String)
    }
    
}
