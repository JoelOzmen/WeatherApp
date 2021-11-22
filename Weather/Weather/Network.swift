//
//  Network.swift
//  Weather
//
//  Created by Joel Özmen on 2021-11-22.
//

import Foundation
import Network

struct Networking{
    
    let monitor = NWPathMonitor()
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            print("We're connected!")
        }
        else {
            print("No connection.")
        }
        print(path.isExpensive)
    }
    
    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
}
