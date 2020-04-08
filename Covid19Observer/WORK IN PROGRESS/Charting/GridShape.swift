//
//  GridShape.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 08.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct GridShape: Shape {
    let steps: Int
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            guard steps > 0 else {
                print("wrong no of steps")
                return
            }
            
            for i in 0...steps {
                let y = rect.height * CGFloat(i) / CGFloat(steps)
                p.addLines([CGPoint(x: 0, y: y),
                            CGPoint(x: rect.width, y: y)
                ])
            }
            
        }
    }
}

struct GridShape_Previews: PreviewProvider {
    static var previews: some View {
        GridShape(steps: 10)
            .stroke(Color.systemGray3, style: StrokeStyle(lineWidth: 0.5, dash: [10, 5]))
            .previewLayout(.sizeThatFits)
    }
}
