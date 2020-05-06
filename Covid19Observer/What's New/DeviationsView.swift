//
//  DeviationsView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 06.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct DeviationsView: View {
    let cardColor: Color = .tertiarySystemFill
    
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    var confirmedDeviations: [Deviation] { coronaStore.confirmedHistory.deviations }
    var deathsDeviations: [Deviation] { coronaStore.deathsHistory.deviations }
    
    @State private var listToShow: [Deviation] = []
    @State private var showCountryList = false
    @State private var kind: DataKind = .confirmedDaily
    
    func deviationButton(kind: DataKind, deviations: [Deviation], color: Color) -> some View {
        Button(action: {
            self.showCountryList = true
            self.listToShow = deviations
            self.kind = kind
        }) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "person.2")
                    .frame(width: 24)
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(kind.id)
                        Spacer()
                        Text("(\(deviations.count.formattedGrouped))")
                    }
                    .font(.subheadline)
                    
                    Divider()
                    
                    /// Paul Hudson : better than .joined(separator: ", ")
                    Text(ListFormatter.localizedString(byJoining: deviations.map { $0.country }))
                        // Text(deviations.map { $0.country }.joined(separator: ", "))
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            .foregroundColor(color)
            .contentShape(Rectangle())
            .padding(12)
            .roundedBackground(cornerRadius: 8, color: cardColor)
        }
    }
    
    
    var body: some View {
        let hasConfirmedDeviations = confirmedDeviations.count > 0
        let hasDeathsDeviations = deathsDeviations.count > 0
        
        return VStack {
            
            !(hasConfirmedDeviations || hasDeathsDeviations)
                ? nil
                : HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text("Significant Deviations")
                        .font(.headline)
                }
                .font(.subheadline)
            
            hasConfirmedDeviations
                ? deviationButton(kind: .confirmedDaily, deviations: confirmedDeviations, color: .confirmed)
                : nil
            
            hasDeathsDeviations
                ? deviationButton(kind: .deathsDaily, deviations: deathsDeviations, color: .deaths)
                : nil
            
            !(hasConfirmedDeviations || hasDeathsDeviations)
                ? Text("No significant changes in confirmed cases or deaths")
                    .foregroundColor(.systemGreen)
                    .font(.subheadline)
                : nil
            
            VStack(alignment: .leading) {
                
                hasConfirmedDeviations || hasDeathsDeviations
                    ? Group {
                        Text("7 days moving average deviations for more than 50%.")
                        Text("Based on history data, not current.\n")
                            .foregroundColor(.systemRed)
                        }
                    : nil
            }
            .padding(.vertical, 8)
            .foregroundColor(.secondary)
            .font(.caption)
        }
        .padding()
        .sheet(isPresented: $showCountryList) {
            CountryList(kind: self.kind, deviations: self.listToShow)
                .environmentObject(self.coronaStore)
                .environmentObject(self.settings)
        }
    }
}

struct DeviationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviationsView()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
