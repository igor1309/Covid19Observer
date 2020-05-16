//
//  CaseBar.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseBar: View {
    @EnvironmentObject var store: Store
    
    let selectedType: CaseDataType
    let index: Int
    let maximum: CGFloat
    let width: CGFloat
    
    let barHeight: CGFloat
    
    var body: some View {
        maximum != 0
            ? ZStack(alignment: .leading) {
                self.selectedType.color
                    .frame(width: width / maximum * self.caseData(self.selectedType, for: index), height: self.barHeight)
                    .cornerRadius(6)
                    .opacity(self.store.currentByCountry.cases[index].name == "China"
                        ? 0.6
                        : self.store.currentByCountry.cases[index].name == "Russia" ? 1 : 0.8)

                
                self.textLabel(name: "\(self.store.currentByCountry.cases[index].name): \(self.caseDataStr(self.selectedType, for: index))",
                    width: width / maximum * self.caseData(self.selectedType, for: index),
                    maxWidth: width)
                }
            : nil
    }
    
    func textLabel(name: String, width: CGFloat, maxWidth: CGFloat) -> some View {
        Text(name)
            .foregroundColor(width > maxWidth / 2
                ? .black
                : self.store.currentByCountry.cases[index].name == "Russia"
                ? .primary : .secondary)
            .font(.footnote)
            .frame(width: width > maxWidth / 2 ? width : maxWidth,
                   alignment: width > maxWidth / 2 ? .trailing : .leading)
            .offset(x: width > maxWidth / 2 ? -10 : width + 10)
    }
    
    private func caseData(_ type: CaseDataType, for index: Int) -> CGFloat {
        switch type {
        case .confirmed:
            return CGFloat(store.currentByCountry.cases[index].confirmed)
        case .new:
            return CGFloat(store.extra.newAndCurrents[index].confirmedNew)
        case .current:
            return CGFloat(store.extra.newAndCurrents[index].confirmedCurrent)
        case .deaths:
            return CGFloat(store.currentByCountry.cases[index].deaths)
        case .cfr:
            return CGFloat(store.currentByCountry.cases[index].cfr)
        }
    }
    
    private func caseDataStr(_ type: CaseDataType, for index: Int) -> String {
        switch type {
        case .confirmed:
            return store.currentByCountry.cases[index].confirmedStr
        case .new:
            return store.extra.newAndCurrents[index].confirmedNewStr
        case .current:
            return store.extra.newAndCurrents[index].confirmedCurrentStr
        case .deaths:
            return store.currentByCountry.cases[index].deathsStr
        case .cfr:
            return store.currentByCountry.cases[index].cfrStr
        }
    }
}
