//
//  TestingCurrentView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 14.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct TestingCurrentView: View {
    @ObservedObject var store = Store()
    
    @State private var isUpdating = false
    
    var body: some View {
        VStack {
            HStack(spacing: 32) {
                
                Circle()
                .stroke(style: StrokeStyle(lineWidth: 16, dash: [3, 1]))
                .fill(AngularGradient(
                    gradient: Gradient(colors: [Color.yellow, .pink, .green, .orange]),
                    center: .center))
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(isUpdating ? 360 : 0))
                .animation(isUpdating
                    ? Animation.linear(duration: 2.1).repeatForever(autoreverses: false)
                    : .default)
                    .onReceive(store.$historyIsUpdating) {
                        self.isUpdating = $0
                }
                
                Button("fetch") {
//                    self.store.fetchCurrent()
//                    self.isUpdating = t
                    self.store.fetchHistory()
                }
            }
            
            List {
                Section(header: Text("last 5 of \(store.currentByCountry.cases.count.formattedGrouped):")) {
                    Text("Confirmed: \(ListFormatter.localizedString(byJoining: store.currentByCountry.cases.suffix(5).map { $0.confirmed.formattedGrouped }))")
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
}

struct TestingCurrentView_Previews: PreviewProvider {
    static var previews: some View {
        TestingCurrentView()
    }
}
