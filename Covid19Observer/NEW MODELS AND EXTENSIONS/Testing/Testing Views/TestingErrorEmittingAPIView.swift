//
//  TestingErrorEmittingAPIView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 16.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TestingErrorEmittingAPIView: View {
    let store = Store(api: ErrorEmittingAPI.shared)
    
    var body: some View {
        WhatsNew()
            .environmentObject(store)
    }
}

struct TestingErrorEmittingAPIView_Previews: PreviewProvider {
    static var previews: some View {
        TestingErrorEmittingAPIView()
    }
}
