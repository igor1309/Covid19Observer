//
//  Extension+View.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension View {
    func widthPreference(column: Int) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WidthPreference.self,
                                value: [column: proxy.size.width])
        })
    }
    
    func roundedBackground(cornerRadius: CGFloat = 12) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .foregroundColor(.tertiarySystemBackground)
                .opacity(0.8)
        )
    }
}
