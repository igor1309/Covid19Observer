//
//  CasesHeaderButton.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesHeaderButton: View {
    @EnvironmentObject var coronaStore: CoronaStore
    @State private var showTable = false
    
    var body: some View {
        Button(action: {
            self.showTable = true
        }) {
            ScrollView(.horizontal, showsIndicators: false) {
                CasesHeader()
            }
        }
        .sheet(isPresented: $showTable, content: {
            CasesTableView()
                .environmentObject(self.coronaStore)
        })
    }
}

struct CasesHeaderButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CasesHeaderButton()
        }
        .environmentObject(CoronaStore())
        .environment(\.colorScheme, .dark)
    }
}
