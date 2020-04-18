//
//  MapHeaderRegular.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// заглушка на будущее
struct MapHeaderRegular: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    var body: some View {
        let updated = coronaStore.timeSinceCasesUpdateStr == "0min"
            ? "just now"
            : "\(coronaStore.timeSinceCasesUpdateStr) ago"
        
        return HStack {
            HStack(alignment: .firstTextBaseline) {
                Text("COVID-19")
                    .font(.subheadline).bold()
                Text("Data by John Hopkins")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            
            CaseTypePicker()
                .frame(maxWidth: 300)
            
            Text("Updated \(updated)")
                .foregroundColor(.tertiary)
                .font(.caption)
        }
        .padding()
        .roundedBackground()
    }
}

struct MapHeaderRegular_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapHeaderRegular()
                .padding()
        }
        .environmentObject(CoronaStore())
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.colorScheme, .dark)
    }
}
