//
//  TestingNearestPointWithHeatedLineChart.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 05.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct TestingNearestPointWithHeatedLineChart: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coronaStore: CoronaStore
    @EnvironmentObject var settings: Settings
    
    @State private var selectedData = "change"
    var series: [Int] {
        if selectedData == "change" {
            return coronaStore.history.change(for: coronaStore.selectedCountry).filtered(limit: settings.isLineChartFiltered ? settings.lineChartLimit : 0)
        } else {
            return coronaStore.history.series(for: coronaStore.selectedCountry).filtered(limit: settings.isLineChartFiltered ? settings.lineChartLimit : 0)
        }
    }
    
    var points: [CGPoint] {
        var pointSeries = [CGPoint]()
        
        guard series.isNotEmpty else { return [] }
        
        for i in 0..<series.count {
            pointSeries.append(CGPoint(x: CGFloat(i),
                                       y: CGFloat(series[i])))
        }
        
        return pointSeries
    }
    
    let lineWidth: CGFloat = 4
    let temperetureGradient = Gradient(colors: [
        .purple,
        Color(red: 0, green: 0, blue: 139.0/255.0),
        .blue,
        Color(red: 30.0/255.0, green: 144.0/255.0, blue: 1.0),
        Color(red: 0, green: 191/255.0, blue: 1.0),
        Color(red: 135.0/255.0, green: 206.0/255.0, blue: 250.0/255.0),
        .green,
        .yellow,
        .orange,
        Color(red: 1.0, green: 140.0/255.0, blue: 0.0),
        .red,
        Color(red: 139.0/255.0, green: 0.0, blue: 0.0)
    ])
    
    var body: some View {
        VStack {
            HStack {
                Toggle("Limit", isOn: $settings.isLineChartFiltered)
                
                Spacer()
                
                Picker(selection: $selectedData, label: Text("Data kind")) {
                    ForEach(["confirmed", "change"], id: \.self) { kind in
                        Text(kind).tag(kind)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
            
            ZStack {
                ChartGrid(xSteps: 10, ySteps: 20)
                    .stroke(Color.systemGray,
                            style: StrokeStyle(lineWidth: 0.5, dash: [12, 6]))
                    .opacity(0.3)
                
                DotChart(points: points)
                    .stroke(LinearGradient(gradient: temperetureGradient,
                                           startPoint: .bottom,
                                           endPoint: .top),
                            style: StrokeStyle(lineWidth: lineWidth,
                                               lineCap: .round,
                                               lineJoin: .round))
                
                NearestPoint(points: points, is2D: false)
            }
        }
    }
}

struct TestingNearestPointWithHeatedLineChart_Previews: PreviewProvider {
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 10),
        CGPoint(x: 10, y: 0),
        CGPoint(x: 20, y: 40),
        CGPoint(x: 30, y: 30),
        //        CGPoint(x: 40, y: 60),
        //        CGPoint(x: 50, y: 140),
        CGPoint(x: 50, y: 180),
        CGPoint(x: 80, y: 200),
        CGPoint(x: 85, y: 200),
        CGPoint(x: 100, y: 190)
    ]
    
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            TestingNearestPointWithHeatedLineChart()
                .padding()
        }
        .environmentObject(CoronaStore())
        .environmentObject(Settings())
        .environment(\.colorScheme, .dark)
    }
}
