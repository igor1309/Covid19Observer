//
//  IndicatorView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// https://github.com/BestKora/ChartsView-SwiftUI/blob/master/RectangleSwiftUI/Graphs/IndicatorView.swift
struct IndicatorView: View {
    var xTime: [String]
    var countryRows: [CountryRow]
    var rangeTime: Range<Int>
    
    @State private var indicatorPosition: CGFloat = 0.3
    @State private var prevTranslation: CGFloat = 0
    
    private var rangeY: Range<Int> {
        let rangeY = rangeOfRanges(
            countryRows
                .filter { $0.isHidden }
                .map { $0.series[rangeTime].min()!..<$0.series[rangeTime].max()! }
        )
        return rangeY == 0..<0 ? 0..<1 : rangeY
    }
    
    private var indicatorIndex: Int {
        let distance = rangeTime.upperBound - rangeTime.lowerBound
        return rangeTime.lowerBound + Int(CGFloat(distance - 1) * indicatorPosition)
    }
    
    private var notHidden: [CountryRow] { countryRows.filter { !$0.isHidden } }
    
    private func betweenValue (yInt: [Int]) -> CGFloat {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en-US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d yyyy")
        
        let doubleInd = Double(rangeTime.lowerBound) + Double(rangeTime.distance - 1 ) * Double(indicatorPosition)
        
        let date1 = dateFormatter.date(from: xTime[indicatorIndex])
        let date2 = dateFormatter.date(from: xTime[indicatorIndex + 1])
        let daysBetween = date2!.days(from: date1!)
        
        let y011 = yInt [indicatorIndex]
        let y012 = yInt [indicatorIndex + 1]
        let y0Between = Double(y012 - y011)
        let gradient = y0Between / Double(daysBetween)
        let y0New = Double(y011) + gradient * (doubleInd - Double(indicatorIndex))
        
        return CGFloat(y0New)
    }
    
    private var legend: some View {
        VStack(alignment: .leading) {
            Text(self.xTime[self.indicatorIndex])
                .foregroundColor(.secondary)
                .font(.footnote)
            
            ForEach(notHidden, id: \.id) { country in
                Text("TBD!")
                    //  MSRK: FIX CRASH WITH betweenValue
//                Text("\(Int(self.betweenValue(yInt: country.series)))")
                    //  MARK: NEED COLOR FROM MODEL??
                    .foregroundColor(.systemOrange)
                    .font(.caption)
            }
        }
        .padding(8)
        .roundedBackground(cornerRadius: 8)
        //  MARK: FINISH WITH OFFSET
//        .offset(legendOffset)
    }


    let strokeColor = Color.systemGray2
    let style = StrokeStyle(lineWidth: 1, dash: [12, 4])

    private func line(height: CGFloat) -> some View {
        Path { path in
            
        }
        .stroke(strokeColor, style: style)
        .opacity(0.5)
        .frame(height: height)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    self.legend
                    .offset(x: self.indicatorPosition < 0.75 ? (-geo.size.width / 2 + 60)  : -265)
                    
                    self.line(height: geo.size.height)
                }
                Spacer()
            }
            .frame(height: geo.size.height)
            .offset(x: self.indicatorPosition * geo.size.width)
            .gesture(DragGesture()
            .onChanged { value in
                withAnimation(.spring()) {
                    let newPosition = self.indicatorPosition + (value.translation.width - self.prevTranslation) / geo.size.width
                    self.indicatorPosition = min(max(newPosition,0),1)
                    self.prevTranslation = value.translation.width
                }
            }
            .onEnded { value in
                self.prevTranslation = 0.0
                }
            )
        }
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static let coronaStore = CoronaStore()
    
    static var rows: [CountryRow] { coronaStore.confirmedHistory.countryRows.filter { $0.name == "Russia" || $0.name == "Italy" } }
    
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
//            LineChartGroup(countryRows: rows, rangeTime: 0..<coronaStore.confirmedHistory.xTime.count - 1)
            
            IndicatorView(
                xTime: coronaStore.confirmedHistory.xTime,
                countryRows: rows,
                rangeTime: 0..<coronaStore.confirmedHistory.xTime.count - 1)
        }
        .environment(\.colorScheme, .dark)
    }
}
