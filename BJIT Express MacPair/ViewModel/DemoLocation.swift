//
//  Data.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 23/5/23.
//
import CoreLocation
import Foundation

class DemoLocation{
    var routes: [[CLLocation]] = []
    
    init() {
        let route1: [CLLocation] = [
            CLLocation(latitude: 37.420373, longitude: -122.143539),
            CLLocation(latitude: 37.414340, longitude: -122.149393),
            CLLocation(latitude: 37.388057, longitude: -122.155857),
            CLLocation(latitude: 37.366848, longitude: -122.135583),
            CLLocation(latitude: 37.358077, longitude: -122.116592),
            CLLocation(latitude: 37.336860, longitude: -122.082717),
            CLLocation(latitude: 37.334207, longitude: -122.077045),
            CLLocation(latitude: 37.334411, longitude: -122.052409),
            CLLocation(latitude: 37.333681, longitude: -122.045652),
            CLLocation(latitude: 37.332331, longitude: -122.031218)
        ]
        
        let route2: [CLLocation] = [
            CLLocation(latitude: 37.368851, longitude: -121.997216),
            CLLocation(latitude: 37.358851, longitude: -121.996216),
            CLLocation(latitude: 37.346865, longitude: -121.995814),
            CLLocation(latitude: 37.339362, longitude: -121.995760),
            CLLocation(latitude: 37.335036, longitude: -122.043347),
            CLLocation(latitude: 37.332543, longitude: -122.0312186)
        ]
        
        let route3: [CLLocation] = [
            CLLocation(latitude: 37.374309, longitude: -122.066892),
            CLLocation(latitude: 37.365633, longitude: -122.063370),
            CLLocation(latitude: 37.349398, longitude: -122.059848),
            CLLocation(latitude: 37.334751, longitude: -122.045545),
            CLLocation(latitude: 37.334342, longitude: -122.040983),
            CLLocation(latitude: 37.334205, longitude: -122.035512),
            CLLocation(latitude: 37.332543, longitude: -122.031558)
        ]
        routes = [route1, route2, route3]
    }
    
    func getRoute() -> [CLLocation]{
        return routes[Int.random(in: 0...(routes.count - 1))]
    }
    
}
