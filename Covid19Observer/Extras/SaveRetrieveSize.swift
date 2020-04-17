//
//  SaveRetrieveSize.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 18.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension View {
    /// https://swiftui-lab.com/view-extensions-for-better-code-readability/
    public func saveSize(viewId: Int) -> some View {
        background(GeometryReader { geo in
            Color.clear.preference(key: SaveSizePrefKey.self,
                                   value: [SaveSizePrefData(viewId: viewId, size: geo.size)])
        })
    }
    
    public func retrieveSize(viewId: Int, _ rect: Binding<CGSize>) -> some View {
        onPreferenceChange(SaveSizePrefKey.self) { preferences in
            DispatchQueue.main.async {
                // The async is used to prevent a possible blocking loop,
                // due to the child and the ancestor modifying each other.
                let p = preferences.first(where: { $0.viewId == viewId })
                rect.wrappedValue = p?.size ?? .zero
            }
        }
    }
}

struct SaveSizePrefData: Equatable {
    let viewId: Int
    let size: CGSize
}

struct SaveSizePrefKey: PreferenceKey {
    static var defaultValue: [SaveSizePrefData] = []
    
    static func reduce(value: inout [SaveSizePrefData], nextValue: () -> [SaveSizePrefData]) {
        value.append(contentsOf: nextValue())
    }
    
    typealias Value = [SaveSizePrefData]
}
