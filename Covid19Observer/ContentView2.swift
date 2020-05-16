//
//  ContentView2.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct ContentView2: View {
    var body: some View {
        TabView {
            WhatsNew()
                .environmentObject(Settings())
                .environmentObject(NotificationsSettings())
                .tabItem {
                    Image(systemName: "0.circle")
                    Text("HomeView")
            }

            TestingHistoricalView()
                .tabItem {
                    Image(systemName: "1.circle")
                    Text("Historical")
            }
            
        }
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
