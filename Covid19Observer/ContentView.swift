//
//  ContentView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 23.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coronaCases: CoronaObservable
    
    var body: some View {
        CasesOnMapView()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CoronaObservable())
            .environment(\.colorScheme, .dark)
    }
}
