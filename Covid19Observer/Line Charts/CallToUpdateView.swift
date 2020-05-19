//
//  CallToUpdateView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CallToUpdateView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        ZStack {
            Color.quaternarySystemFill
            
            VStack {
                Text ("No Data to display.")
                    .foregroundColor(.secondary)
                    .font(.headline)
                
                if self.settings.chartOptions.isFiltered {
                    Text ("Please check the filter.")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    LineChartFilterToggle()
                }
                
                SpinningWaitHistoryButton()
            }
        }
    }
}

struct CallToUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CallToUpdateView()
                
                .padding()
        }
        .environmentObject(Settings())
        .environmentObject(Store())
        .environment(\.colorScheme, .dark)
    }
}
