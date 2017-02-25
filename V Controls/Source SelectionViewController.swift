//
//  Source SelectionViewController.swift
//  V Controls
//
//  Created by George Koepplinger on 2/13/15.
//  Copyright (c) 2015 George Koepplinger. All rights reserved.
//

import UIKit


class Source_SelectionViewController: UIViewController
{
//    let Vswitch = BCDDeviceControl (device: "Enova DGX", inChans: 4, outChans: 8, hostIP: "10.0.1.31", portID: 4660)
    
    @IBAction func SelectSource(_ sender: UISegmentedControl)
    {
 /*       if (Vswitch.connected())
        {
            println ("zone = \(sender.tag)   source = \(sender.selectedSegmentIndex)")
            
            Vswitch.setRoute (sender.selectedSegmentIndex+1, outChan: sender.tag+1)
            
            getSwitchStatus()
        }
        else
        {
            switchSources[sender.tag].selected = false
        } */
    }
    
    @IBOutlet var switchSources: [UISegmentedControl]!
  
/*
    func updateSourceControls ()
    {
        for i in 0...Vswitch.outChans-1
        {
            switchSources[i].selectedSegmentIndex = Vswitch.routes[i]
        }

    }
    
    func getSwitchStatus ()
    {
        let wait = 0.75
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: Selector("updateSourceControls"), userInfo: nil, repeats: false);
        
        Vswitch.getRoutes()
    }
    
 //   func connectSwitch ()
 //   {
 //       if (!Vswitch.connected())
 //       {
 //
 //       }
 //       Vswitch.connect()
 //   }
*/
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
       // let wait = 5.0
        
       // var timer =  NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: Selector("connectSwitch"), userInfo: nil, repeats: false);

       // timer.fire()
 //         Vswitch.connect()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)

 //       getSwitchStatus()
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
