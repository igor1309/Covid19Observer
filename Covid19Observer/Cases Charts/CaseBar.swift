//
//  CaseBar.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CaseBar: View {
    @EnvironmentObject var coronaStore: CoronaStore
    
    let selectedType: CaseDataType
    let index: Int
    let maximum: CGFloat
    let width: CGFloat
    
    let barHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            self.selectedType.color
                .frame(width: width / maximum * self.caseData(self.selectedType, for: index), height: self.barHeight)
                .cornerRadius(6)
                .saturation(self.coronaStore.cases[index].name == "China" ? 0.3 : 1)
            
            self.textLabel(name: "\(self.coronaStore.cases[index].name): \(self.caseDataStr(self.selectedType, for: index))",
                width: width / maximum * self.caseData(self.selectedType, for: index),
                maxWidth: width)
        }
    }
    
    func textLabel(name: String, width: CGFloat, maxWidth: CGFloat) -> some View {
        Text(name)
            .foregroundColor(width > maxWidth / 2 ? .black : .secondary)
            .font(.footnote)
            .frame(width: width > maxWidth / 2 ? width : maxWidth,
                   alignment: width > maxWidth / 2 ? .trailing : .leading)
            .offset(x: width > maxWidth / 2 ? -10 : width + 10)
    }
    
    private func caseData(_ type: CaseDataType, for index: Int) -> CGFloat {
        switch type {
        case .confirmed:
            return CGFloat(coronaStore.cases[index].confirmed)
        case .new:
            return CGFloat(coronaStore.cases[index].newConfirmed)
        case .current:
            return CGFloat(coronaStore.cases[index].currentConfirmed)
        case .deaths:
            return CGFloat(coronaStore.cases[index].deaths)
        case .cfr:
            return CGFloat(coronaStore.cases[index].cfr)
        }
    }
    
    private func caseDataStr(_ type: CaseDataType, for index: Int) -> String {
        switch type {
        case .confirmed:
            return coronaStore.cases[index].confirmedStr
        case .new:
            return coronaStore.cases[index].newConfirmedStr
        case .current:
            return coronaStore.cases[index].currentConfirmedStr
        case .deaths:
            return coronaStore.cases[index].deathsStr
        case .cfr:
            return coronaStore.cases[index].cfrStr
        }
    }
}

//struct CaseBar_Previews: PreviewProvider {
//    static var previews: some View {
//        CaseBar(selectedType: <#T##CaseDataType#>, index: <#T##Int#>, maximum: <#T##CGFloat#>, width: <#T##CGFloat#>)
//    }
//}
