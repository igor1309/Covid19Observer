//
//  MapHeaderCompact.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct MapHeaderCompact: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    var body: some View {
        let updated = coronaStore.timeSinceCasesUpdateStr == "0min"
            ? "just now"
            : "\(coronaStore.timeSinceCasesUpdateStr) ago"
        
        return VStack {
            HStack(alignment: .firstTextBaseline) {
                Text("COVID-19")
                    .font(.subheadline).bold()
                Text("Data by John Hopkins")
                    .font(.caption)
            }
            
            Text("Updated \(updated)")
                .foregroundColor(.tertiary)
                .font(.caption)
                .padding(.top, 6)
            
            CaseTypePicker()
        }
        .padding()
        .roundedBackground()
    }
}

struct MapHeaderCompact_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                MapHeaderCompact()
                    .padding()
                Spacer()
            }
        }
        .environmentObject(CoronaStore())
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.colorScheme, .dark)
    }
}
