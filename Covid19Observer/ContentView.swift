//
//  ContentView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
            .environmentObject(CoronaStore())
            .environmentObject(Store())
            .environmentObject(Settings())
            .environmentObject(NotificationsSettings())
            
            .onReceive(NotificationCenter.default
                .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    //  MARK: ???
                    //
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Store())
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
    }
}
