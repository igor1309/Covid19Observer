//
//  SaveRetrieveBounds.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 17.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension View {
    /// https://swiftui-lab.com/view-extensions-for-better-code-readability/
    public func saveBounds(viewId: Int, coordinateSpace: CoordinateSpace = .global) -> some View {
        background(GeometryReader { geo in
            Color.clear.preference(key: SaveBoundsPrefKey.self,
                                   value: [SaveBoundsPrefData(viewId: viewId, bounds: geo.frame(in: coordinateSpace))])
        })
    }
    
    public func retrieveBounds(viewId: Int, _ rect: Binding<CGRect>) -> some View {
        onPreferenceChange(SaveBoundsPrefKey.self) { preferences in
            DispatchQueue.main.async {
                // The async is used to prevent a possible blocking loop,
                // due to the child and the ancestor modifying each other.
                let p = preferences.first(where: { $0.viewId == viewId })
                rect.wrappedValue = p?.bounds ?? .zero
            }
        }
    }
}

struct SaveBoundsPrefData: Equatable {
    let viewId: Int
    let bounds: CGRect
}

struct SaveBoundsPrefKey: PreferenceKey {
    static var defaultValue: [SaveBoundsPrefData] = []
    
    static func reduce(value: inout [SaveBoundsPrefData], nextValue: () -> [SaveBoundsPrefData]) {
        value.append(contentsOf: nextValue())
    }
    
    typealias Value = [SaveBoundsPrefData]
}
