//
//  CaseAnnotationView.swift
//  Covid19Observer
//
//  Created by Igor Malyarov on 26.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import MapKit

class CaseAnnotationView: MKPinAnnotationView {
    
    /// https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    override var annotation: MKAnnotation? {
        willSet {
            guard let caseAnnotation = newValue as? CaseAnnotation else { return }
            
            pinTintColor = caseAnnotation.color
            
            let subtitleLabel = UILabel()
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.text = caseAnnotation.subtitle ?? "NA"
            subtitleLabel.numberOfLines = 0
            subtitleLabel.font = .preferredFont(forTextStyle: .footnote)
            subtitleLabel.textColor = .secondaryLabel
            self.detailCalloutAccessoryView = subtitleLabel
            
            canShowCallout = true
            let mapIcon = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            mapIcon.setBackgroundImage(UIImage(systemName: "waveform.path.ecg"), for: UIControl.State())
            rightCalloutAccessoryView = mapIcon
        }
    }
}
