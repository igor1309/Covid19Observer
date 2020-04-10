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
                footer: Text("")) {
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
    
    var deviations: some View {
        Section(header: Text("Deviations".uppercased()),
                footer: Text("7 days moving average deviations for more than 20%.")
        ) {
            NavigationLink(
                destination: Text("<list if countries??>")
            ) {
                Text("confirmed cases: 7 countries")
            }
            
            NavigationLink(
                destination: Text("<list if countries??>")
            ) {
                Text("deaths: 5 countries")
            }
            
            NavigationLink(
                destination: Text("<list if countries??>")
            ) {
                Text("CFR ???? - надо ли?")
            }
        }
    }
    
    var  body: some View {
        NavigationView {
            Form {
                confirmed
                
                deaths
                
                deviations
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
