//
//  HomeViewModel.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 19/5/23.
//

import Foundation
import Combine

class HomeViewModel:ObservableObject{
    @Published var checkedInTime = Date()
    @Published var durationInSecond:Int = 0
    @Published var distanceInMeter:Int = 0
    
    init() {
        
    }
}
