//
//  LineChartSettingsView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 19.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct LineChartSettingsView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            Form {
                LineChartSettingsSection()
            }
            .navigationBarTitle("Chart Options")
            .navigationBarItems(trailing: Button("Done") {
                self.presentation.wrappedValue.dismiss()
            })
        }
    }
}

struct LineChartSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartSettingsView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Settings())
    }
}
