//
//  Weather.swift
//  WeatherAPP2
//
//  Created by DeepThought on 30/09/2016.
//  Copyright © 2016 Jake. All rights reserved.
//

import Foundation

struct Weather {
    
    let temperature:Float
    let description:String
    
}

extension Weather {
    
    init?(json:[String:Any]) {
        
        guard let weatherArray = json["weather"] as? [[String:Any]],
            description = weatherArray.first?["description"] as? String else {
            return nil
        }
        
        guard let main = json["main"] as? [String:Any],
                temperature = main["temp"] as? Float else {
            return nil
        }
        
        self.description = description
        self.temperature = temperature
    }
    
}
