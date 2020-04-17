//
//  AppendCurrentToggle.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 17.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct AppendCurrentToggle: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        ToolBarButton(systemName: settings.appendCurrent ? "sun.max.fill" : "sun.min") {
            self.settings.appendCurrent.toggle()
        }
        .foregroundColor(settings.appendCurrent ? .systemPurple : .secondary)
    }
}

struct AppendCurrentToggle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            AppendCurrentToggle()
        }
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
