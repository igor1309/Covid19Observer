//
//  CountryList.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 11.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CountryList: View {
    
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    var kind: DataKind
    var deviations: [Deviation]
    
    @State private var showCountryDetails = false
    @State private var columnWidths: [Int: CGFloat] = [200:100]
    
    func deviationRow(deviation: Deviation, kind: DataKind) -> some View {
        
        var change: Double { deviation.last / deviation.avg - 1 }
        var color: Color {
            change >= 1 ? .systemRed
                : change >= 0.5 ? .systemOrange
                : change < 0 ? .systemTeal
                : .secondary
        }
        
        return HStack(alignment: .firstTextBaseline) {
            Text(deviation.country)
            Spacer()
            Group {
                cell(text: deviation.avg.formattedGrouped, col: 220)
                cell(text: deviation.last.formattedGrouped, col: 221)
                cell(text: change.formattedPercentage, col: 222)
            }
            .font(.subheadline)
        }
        .foregroundColor(color)
        .padding(.vertical, 8)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture {
            self.coronaStore.selectedCountry = deviation.country
            self.settings.chartOptions.dataKind = kind
            self.showCountryDetails = true
        }
        .sheet(isPresented: self.$showCountryDetails) {
            CasesLineChartView(forAllCountries: false)
                .padding(.top, 6)
                .environmentObject(self.coronaStore)
                .environmentObject(self.settings)
        }
    }
    
    func cell(text: String, col: Int) -> some View {
        Text(text)
            .fixedSize()
            .widthPreference(column: col)
            .frame(width: columnWidths[col], alignment: .trailing)
            .padding(.leading)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            VStack {
                Text("Significant changes in")
                Text(kind.id)
                    .font(.title)
            }
            .padding(.top)
            .padding(/*[.top, .horizontal]*/)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Country")
                Spacer()
                Group {
                    cell(text: "7d avg", col: 220)
                    cell(text: "laset", col: 221)
                    cell(text: "change", col: 222)
                }
            }
            .foregroundColor(.secondary)
            .font(.footnote)
            .padding(.horizontal)
            
            ScrollView(.vertical) {
                VStack {
                    ForEach(deviations.indices) { ix in
                        self.deviationRow(deviation: self.deviations[ix], kind: self.kind)
                            .background(ix % 2 == 0 ? Color.secondarySystemBackground : .clear)
                    }
                }
            }
        }
        .onPreferenceChange(WidthPreference.self) { self.columnWidths = $0 }
    }
}

struct CountryList_Previews: PreviewProvider {
    static var deviations: [Deviation] {
        var devs = [Deviation]()
        let countries = ["Russia", "US", "Italy", "Germany", "France", "Finland", "Spain", "China"]
        for country in countries {
            devs.append(Deviation(country: country, avg: 30, last: 40))
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
