//
//  CountryList.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct DeviationRow: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var showCountryDetails = false
    
    var deviation: Deviation
    var kind: DataKind
    
    var change: Double { deviation.last / deviation.avg - 1 }
    var color: Color {
        change >= 1 ? .systemRed
            : change >= 0.5 ? .systemOrange
            : change < 0 ? .systemTeal
            : .secondary
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(deviation.country)
            Spacer()
            Group {
                Text(deviation.avg.formattedGrouped)
                    .frame(width: 72, alignment: .trailing)
                Text(deviation.last.formattedGrouped)
                    .frame(width: 72, alignment: .trailing)
                Text(change.formattedPercentage)
                    .frame(width: 60, alignment: .trailing)
            }
            .font(.subheadline)
        }
        .foregroundColor(color)
        .contentShape(Rectangle())
        .onTapGesture {
            self.coronaStore.selectedCountry = self.deviation.country
            self.settings.selectedDataKind = self.kind
            self.showCountryDetails = true
        }
        .sheet(isPresented: self.$showCountryDetails) {
            CasesLineChartView()
                .padding(.top, 6)
                .environmentObject(self.coronaStore)
                .environmentObject(self.settings)
        }
    }
}

struct CountryList: View {
    var kind: DataKind
    var deviations: [Deviation]
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Significant changes in \(kind.id)")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(/*[.top, .horizontal]*/)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Country")
                Spacer()
                Group {
                    Text("7d avg")
                        .frame(width: 72, alignment: .trailing)
                    Text("last")
                        .frame(width: 72, alignment: .trailing)
                    Text("change")
                        .frame(width: 60, alignment: .trailing)
                }
            }
            .foregroundColor(.secondary)
            .font(.footnote)
            .padding(.horizontal)
            
            ScrollView(.vertical) {
                VStack {
                    ForEach(deviations.indices) { ix in
                        DeviationRow(deviation: self.deviations[ix], kind: self.kind)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(ix % 2 == 0 ? Color.secondarySystemBackground : .clear)
                    }
                }
            }
        }
    }
}

struct CountryList_Previews: PreviewProvider {
    static var deviations: [Deviation] {
        var devs = [Deviation]()
        for country in PrimeCountries.allCases {
            devs.append(Deviation(country: country.name, avg: 30, last: 40))
        }
        return devs
    }
    
    static var previews: some View {
        NavigationView {
            CountryList(kind: .confirmedDaily, deviations: deviations)
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
