//
//  TestingHistoricalView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 13.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct TestingHistoricalView: View {
    @EnvironmentObject var store: Store
    
    let country = "Russia"
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button("testing") {
                        self.store.testing()
                    }
                    Spacer()
                    Button("fetch") {
                        self.store.fetchHistory()
                    }
                    Spacer()
                    Spacer()
                    Button("reset Outbreak") {
                        self.store.resetOutbreak()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                List {
                    
                    Section(header: Text("Corona cases".uppercased())) {
                        Text("corona cases: \(ListFormatter.localizedString(byJoining: store.currentByCountry.cases.suffix(3).map { String($0.name) }))")
                            .font(.footnote)
                    }
                    
                    Section(header: Text(country.uppercased())) {
                        Text("last 5")
                        ForEach([store.confirmedHistory, store.deathsHistory], id: \.self) { history in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(history.type.rawValue + " last: \(history.last(for: self.country).formattedGrouped), previous: \(history.previous(for: self.country).formattedGrouped)")
                                    .font(.footnote)
                                Group {
                                    Text("daily change: \(ListFormatter.localizedString(byJoining: history.dailyChange(for: self.country).suffix(5).map { $0.formattedGrouped }))")
                                    Text("series: \(ListFormatter.localizedString(byJoining: history.series(for: self.country).suffix(5).map { $0.formattedGrouped }))")
                                }
                                .foregroundColor(.secondary)
                                .font(.caption)
                            }
                        }
                    }
                    
                    Section(header: Text("History".uppercased())) {
                        ForEach([store.confirmedHistory, store.deathsHistory], id: \.self) { history in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(history.type.rawValue) (last 5):")
                                Text("allCountriesTotals (count: \(history.allCountriesTotals.count.formattedGrouped)) \(ListFormatter.localizedString(byJoining: history.allCountriesTotals.suffix(5).map { $0.formattedGrouped }))")
                                    .font(.caption)
                                Text("allCountriesDailyChange (count: \(history.allCountriesDailyChange.count.formattedGrouped)) \(ListFormatter.localizedString(byJoining: history.allCountriesDailyChange.suffix(5).map { $0.formattedGrouped }))")
                                    .font(.caption)
                                Text("xLabels (count: \(history.xLabels.count.formattedGrouped)) \(ListFormatter.localizedString(byJoining: history.xLabels.suffix(5)))")
                                    .font(.footnote)
                                Text(self.store.historySyncInfo.text)
                                    .foregroundColor(self.store.historySyncInfo.color)
                                    .font(.footnote)
                                Text("last update: \(self.store.historySyncInfo.text)")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                    
                    Section(header: Text("Deviations".uppercased())) {
                        ForEach([store.confirmedVariation, store.deathsVariation], id: \.self) { deviations in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(deviations.type.rawValue + " avg/last")
                                Text(ListFormatter.localizedString(byJoining: deviations.deviations.map { "\($0.country) \($0.avg.formattedGrouped)/\($0.last.formattedGrouped)" }))
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
                
            .overlay(WidgetOverlay { CasesChartWidget() })
        }
    }
}

struct TestingHistoricalView_Previews: PreviewProvider {
    static var previews: some View {
        TestingHistoricalView()
            .environmentObject(Store())
    }
}
