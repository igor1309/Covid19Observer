//
//  LineChartFilterToggle.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 17.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineChartFilterToggle: View {
        @EnvironmentObject var settings: Settings
        
        var body: some View {
            ToolBarButton(systemName: "line.horizontal.3.decrease") {
                self.settings.isLineChartFiltered.toggle()
            }
            .foregroundColor(settings.isLineChartFiltered ? .systemOrange : .systemBlue)
        }
    }

    struct LineChartFilterToggle_Previews: PreviewProvider {
        static var previews: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                LineChartFilterToggle()
            }
            .environmentObject(Settings())
            .environment(\.colorScheme, .dark)
        }
    }
