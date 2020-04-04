//
//  PreferenceKeys.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct WidthPreference: PreferenceKey {
    typealias Value = [Int: CGFloat]
    
    static let defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: max)
    }
}

struct WidthPref: PreferenceKey {
    typealias Value = CGFloat
    
    static let defaultValue: CGFloat = 100
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let nextValue = nextValue()
        if nextValue > value {
            value = nextValue
        }
    }
}

struct HeightPref: PreferenceKey {
    typealias Value = CGFloat
    
    static let defaultValue: CGFloat = 100
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let nextValue = nextValue()
        if nextValue > value {
            value = nextValue
        }
    }
}

extension View {
    func widthPreference(column: Int) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: WidthPreference.self,
                                value: [column: geo.size.width])
        })
    }
    
    func widthPref() -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: WidthPref.self,
                                value: geo.size.width)
        })
    }
    
    func heightPref() -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HeightPref.self,
                                value: geo.size.height)
        })
    }
}
