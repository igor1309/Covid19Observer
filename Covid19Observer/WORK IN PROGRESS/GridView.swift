//
//  GridView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 04.04.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct GridView: View {
    var size = CGSize(width: 30, height: 30)
    var body: some View {
        let image = Image(uiImage: gridImage(size: size))
        
        return Rectangle()
            .fill(ImagePaint(image: image))
//            .edgesIgnoringSafeArea(.all)
        
    }
    
    func gridImage(size: CGSize) -> UIImage {
        let width = size.width
        let height = size.height
        
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.lightGray.setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.stroke()
        }
        
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView()
    }
}
