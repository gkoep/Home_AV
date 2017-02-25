//
//  VolumeControlViewController.swift
//  V Controls
//
//  Created by George Koepplinger on 2/13/15.
//  Copyright (c) 2015 George Koepplinger. All rights reserved.
//

import UIKit


class VolumeControlViewController: UIViewController
{
 
    let vSwitch   = BCDDeviceControl (device: "Enova DGX",  inChans: 5, outChans: 8, hostIP: "10.0.1.31", portID: 4660)
    
    let audioProc = BCDDeviceControl (device: "Precis DSP", inChans: 8, outChans: 8, hostIP: "10.0.1.31", portID: 4661)
 
    
    @IBOutlet var connect: UIButton!
  
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet var zoneVolumes: [UISlider]!
    
    @IBOutlet var zoneMutes: [UISwitch]!
    
    @IBOutlet var switchSources: [UISegmentedControl]!
  
    
    @IBAction func connect(_ sender: UIButton)
    {
     //   println("connect \(sender.touchInside)")
      //  connectDevices()
    }
    
    
    @IBAction func ChangeVolume(_ sender: UISlider)
    {
        var dbVol: Float
        
        if (audioProc.connected())
        {
            if (!sender.isTracking && sender.isTouchInside)
            {
                if (sender.value <= 0.5)
                {
                    dbVol = 70*sender.value - 30.0
                }
                else
                {
                    dbVol = 11.0*sender.value - 5.0
                }
              //  println("zone = \(sender.tag)   dB vol = \(dbVol)")
                
                audioProc.setVolume (dbVol, outChan: sender.tag+1)
                getDeviceStatus()
            }
        }
        else
        {
           // zoneVolumes[sender.tag].value = 0.0000001
            connectAudioProc()
        }
    }
    
    @IBAction func MuteVolume(_ sender: UISwitch)
    {
        if (audioProc.connected())
        {
        //    println("zone = \(sender.tag)   muted = \(!sender.on)")
            audioProc.setMute (!sender.isOn, outChan: sender.tag+1)
            
            getDeviceStatus()
        }
        else
        {
            zoneMutes[sender.tag].isOn = !sender.isOn
            connectAudioProc()
        }
    }
    
    
    @IBAction func selectSource(_ sender: UISegmentedControl)
    {
        if (vSwitch.connected())
        {
       //     println ("zone = \(sender.tag)   source = \(sender.selectedSegmentIndex)")
            
            vSwitch.setRoute (sender.selectedSegmentIndex+1, outChan: sender.tag+1)
            
            getDeviceStatus()
        }
        else
        {
            switchSources[sender.tag].isSelected = false
            connectSwitch()
        }
    }
    
    
    func updateDeviceControls ()
    {
        for i in 0...vSwitch.outChans-1
        {
            self.switchSources[i].selectedSegmentIndex = vSwitch.routes[i]
        }
        
        for i in 0...audioProc.outChans-1
        {
            if (audioProc.volumes[i] <= 0.5)
            {
                self.zoneVolumes[i].value = (audioProc.volumes[i] + 30.0) / 70.0
            }
            else
            {
                self.zoneVolumes[i].value = (audioProc.volumes[i] + 5.0) / 11.0
            }
        //    println("volume slider = \(self.zoneVolumes[i].value)")
            
            self.zoneMutes[i].isOn = !audioProc.mutes[i]
        }
        activityIndicator.stopAnimating()
    }
    
    func getDeviceStatus ()
    {
        let wait = 3.0
        
        var switchTimer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(VolumeControlViewController.updateDeviceControls), userInfo: nil, repeats: false);
        
        vSwitch.getRoutes()
        audioProc.getVolumes()
    }
    
    func connectAudioProc ()
    {
        if (!audioProc.connected())
        {
            audioProc.connect()
            
            let wait = 2.0
            
            var timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(VolumeControlViewController.getDeviceStatus), userInfo: nil, repeats: false);
            
            activityIndicator.startAnimating()
        }
    }
    
    func connectSwitch ()
    {
        if (!vSwitch.connected())
        {
            vSwitch.connect()
            
            let wait = 2.0
            
            var timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(VolumeControlViewController.getDeviceStatus), userInfo: nil, repeats: false);
            
            activityIndicator.startAnimating()
        }
    }

    func checkConnection ()
    {
        if (audioProc.connected() && vSwitch.connected())
        {
            self.connect.isHighlighted = true
        }
        else
        {
            self.connect.isHighlighted = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   let wait = 5.0
        
     //   var timer = NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: Selector("connectDevices"), userInfo: nil, repeats: true);
        
     //   timer.fire()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        
  //      let wait = 1.0
        
  //      var timer = NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: Selector("checkConnection"), userInfo: nil, repeats: true);
   //
  //      timer.fire()
        
        connectAudioProc ()
        
        connectSwitch ()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
