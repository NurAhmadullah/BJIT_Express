//
//  TabViews.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 11/5/23.
//

import SwiftUI

struct TabViews: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            BusLayoutView()
                .tabItem {
                    Image(systemName: "bus.fill")
                    Text("Seats")
                }
            PassengerListView()
                .tabItem {
                    Image(systemName: "person.crop.rectangle.stack.fill")
                    Text("Passengers")
                }
        }.accentColor(.green)
    }
}

struct TabViews_Previews: PreviewProvider {
    static var previews: some View {
        TabViews()
    }
}
