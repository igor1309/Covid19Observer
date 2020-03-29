//
//  CasesChartsIPad.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 29.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct CasesChartsIPad: View {
    var body: some View {
        VStack {
            HStack {
                //  MARK: FIX THIS
                //  no need in button, just data
                CasesHeaderButton()
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            GeometryReader { geo in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        HStack {
                            CaseChart(
                                selectedType: CaseDataType.confirmed,
                                width: geo.size.width / 3)
                            CaseChart(
                                selectedType: CaseDataType.deaths,
                                width: geo.size.width / 3)
                            CaseChart(
                                selectedType: CaseDataType.cfr,
                                width: geo.size.width / 3)
                        }
                    }
                }
            }
        }
    }
}

struct CasesChartsIPad_Previews: PreviewProvider {
    static var previews: some View {
        CasesChartsIPad()
    }
}
