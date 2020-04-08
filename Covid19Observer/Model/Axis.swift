//
//  Axis.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 08.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

/// Create nice axis scale for datapoints
struct Axis {
    let points: [CGFloat]
    var percent: CGFloat = 0
    
    let bottom, top: CGFloat
    let steps: Int
    
    init(for points: [CGFloat], percent: CGFloat = 0) {
        self.points = points
        self.percent = percent
        
        guard points.isNotEmpty else {
            print("no points for axis parameters")
            //  MARK: returns 1 juct in case od division by zero
            self.bottom = .zero
            self.top = 1
            self.steps = 1
            return
        }
        
        /// get min and max from dataset and apply percentage for wider axis scale
        //  MARK: FIX THIS FOR NEGATIVE VALUES!!!
        //  MARK: FILTER MAKES PROBLEM????
        let minPoint = points.map { $0 }.min()! * (1 - percent)
        let maxPoint = points.map { $0 }.max()! * (1 + percent)
//        print("minPoint: \(minPoint) | maxPoint: \(maxPoint)")
        
        let maxSteps: CGFloat = 10
        let stepSize = (maxPoint - minPoint) / (maxSteps - 1)
        
        
        /// https://stackoverflow.com/questions/237220/tickmark-algorithm-for-a-graph-axis
        let goodNormalizedSteps: [CGFloat] = [1, 2, 5, 10]
        
        // Normalize rough step to find the normalized one that fits best
        let stepPower = pow(10, -(log10(abs(stepSize))).rounded(.down))
        let normalizedStep = stepSize * stepPower
        let goodNormalizedStep = goodNormalizedSteps.first { $0 >= normalizedStep }!
        let step = goodNormalizedStep / stepPower
        
        
        let bottom = (minPoint / step).rounded(.down) * step
        let top = (maxPoint / step).rounded(.up) * step
        
        let steps = (top - bottom) / step
        
        self.bottom = bottom
        self.top = top
        //  MARK: - FINISH THIS
        self.steps = Int(steps)
    }
}

