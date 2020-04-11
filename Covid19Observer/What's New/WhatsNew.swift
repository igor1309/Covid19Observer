//
//  WhatsNew.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct WhatsNew: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    var confirmedDeviations: [Deviation] { coronaStore.confirmedHistory.deviations }
    var deathsDeviations: [Deviation] { coronaStore.deathsHistory.deviations }
    
    var confirmed: some View {
        Section(header: Text("Confirmed".uppercased()),
                footer: updated) {
                    HStack {
                        Text("Confirmed Cases")
                        Spacer()
                        Text(coronaStore.coronaOutbreak.totalCases)
                    }
                    .foregroundColor(.systemYellow)
                    
                    HStack {
                        Text("New, \((-5.3/100).formattedPercentage)")
                        Spacer()
                        Text(coronaStore.coronaOutbreak.totalNewConfirmed)
                    }
                    .foregroundColor(.systemOrange)
                    
                    HStack {
                        Text("Current, \(5.3 > 0 ? "+" : "-")\((5.3/100).formattedPercentage)")
                        Spacer()
                        Text(coronaStore.coronaOutbreak.totalNewConfirmed)
                    }
                    .foregroundColor(.systemPurple)
        }
    }
    
    var deaths: some View {
        Section(header: Text("Deaths".uppercased()),
                footer: Text("")
        ) {
            VStack {
                Group {
                    HStack {
                        Text("Deaths")
                        Spacer()
                        Text(coronaStore.coronaOutbreak.totalDeaths)
                    }
                    .foregroundColor(.systemRed)
                    
                    HStack {
                        Text("New, \((-5.3/100).formattedPercentage)")
                        Spacer()
                        Text(coronaStore.coronaOutbreak.totalNewConfirmed)
                    }
                    .foregroundColor(.systemOrange)
                    
                    HStack {
                        Text("Current, \(5.3 > 0 ? "+" : "-")\((5.3/100).formattedPercentage)")
                        Spacer()
                        Text(coronaStore.coronaOutbreak.totalNewConfirmed)
                    }
                    .foregroundColor(.systemPurple)
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    var updated: some View {
        Text(coronaStore.timeSinceCasesUpdateStr == "0min"
            ? "Cases updated just now."
            : "Last update for Cases \(coronaStore.timeSinceCasesUpdateStr) ago.")
            + Text(" ")
            + Text(coronaStore.confirmedHistory.timeSinceUpdateStr == "0min"
                ? "History updated just now/"
                : "Last update for History \(coronaStore.confirmedHistory.timeSinceUpdateStr) ago.")
    }
    
    @State private var listToShow: [Deviation] = []
    @State private var showCountryList = false
    @State private var kind: DataKind = .confirmedDaily
    
    func deviationRow(kind: DataKind, deviations: [Deviation], color: Color) -> some View {
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(kind.id) jump/fall")
                Spacer()
                Text("(\(deviations.count.formattedGrouped))")
                    .font(.subheadline)
            }
            .foregroundColor(color)
            
            Text(deviations.map { $0.country }.joined(separator: ", "))
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.showCountryList = true
            self.listToShow = deviations
            self.kind = kind
        }
    }
    
    var deviations: some View {
        Section(header: Text("Significant Deviations".uppercased()),
                footer: VStack(alignment: .leading) {
                    Text("7 days moving average deviations for more than 50%.")
                    Text("Based on history data, not current.\n")
                        .foregroundColor(.systemRed)
                    updated
            }
        ) {
            confirmedDeviations.count > 0
                ? deviationRow(kind: .confirmedDaily, deviations: confirmedDeviations, color: .systemOrange)
                : nil
            
            deathsDeviations.count > 0
                ? deviationRow(kind: .deathsDaily, deviations: deathsDeviations, color: .systemRed)
                : nil
            
            confirmedDeviations.count == 0 && deathsDeviations.count == 0
                ? Text("No significant changes in confirmed cases or deaths")
                    .foregroundColor(.systemGreen)
                    .font(.subheadline)
                : nil
            
            Text("CFR ???? - надо ли?").foregroundColor(.systemTeal)
        }
        
    }
    
    var  body: some View {
        VStack {
            Text("What's New")
                .font(.title)
            Form {
                deviations
                    .sheet(isPresented: $showCountryList) {
                        CountryList(kind: self.kind, deviations: self.listToShow)
                            .environmentObject(self.coronaStore)
                            .environmentObject(self.settings)
                }
                
                updated
                
                confirmed
                
                deaths
                
            }
            .navigationBarTitle(Text("What's New"))
        }
    }
}

struct WhatsNew_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            WhatsNew()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
    }
}
