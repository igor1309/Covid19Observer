//
//  Extension+View.swift
//  SwiftUICoronaMapTracker
//
//  Created by Igor Malyarov on 22.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

extension View {
    
    func roundedBackground(cornerRadius: CGFloat = 12, color: Color = .tertiarySystemBackground) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
                .opacity(0.8)
        )
    }
}
