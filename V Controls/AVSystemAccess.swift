//
//  AVSystemAccess.swift
//  V Controls
//
//  Created by George Koepplinger on 2/16/15.
//  Copyright (c) 2015 George Koepplinger. All rights reserved.
//

import Foundation


class AVSystemAccess
{
    enum AVZones: Int {
        case recRoomL = 0
        case recRoomR = 1
        case sunRoom  = 2
        case office   = 3
        case shops    = 4
        case gym      = 5
        case balcony  = 6
        case backyard = 7
    }
    
    enum AVSources: Int {
        case satv_1 = 0
        case satv_2 = 1
        case atv    = 2
        case dvd    = 3
    }
    
    var activeZone : AVZones
    
    var zoneSource: [AVZones: AVSources] = [AVZones.recRoomL: AVSources.satv_1, AVZones.recRoomR: AVSources.satv_1,
                                            AVZones.sunRoom:  AVSources.satv_1, AVZones.office:   AVSources.satv_1,
                                            AVZones.shops:    AVSources.satv_1, AVZones.gym:      AVSources.satv_1,
                                            AVZones.balcony:  AVSources.satv_1, AVZones.backyard: AVSources.satv_1]
    
    init(){
        activeZone = AVZones.recRoomL
        
    }
    
    
}

