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
            
            let confirmedLabel = UILabel()
            confirmedLabel.translatesAutoresizingMaskIntoConstraints = false
            confirmedLabel.text = caseAnnotation.confirmed ?? "NA"
            confirmedLabel.numberOfLines = 0
            confirmedLabel.font = .preferredFont(forTextStyle: .footnote)
            confirmedLabel.textColor = UIColor.confirmed

            let deathsLabel = UILabel()
            deathsLabel.translatesAutoresizingMaskIntoConstraints = false
            deathsLabel.text = caseAnnotation.deaths ?? "NA"
            deathsLabel.numberOfLines = 0
            deathsLabel.font = .preferredFont(forTextStyle: .footnote)
            deathsLabel.textColor = UIColor.deaths

            let cfrLabel = UILabel()
            cfrLabel.translatesAutoresizingMaskIntoConstraints = false
            cfrLabel.text = caseAnnotation.cfr ?? "NA"
            cfrLabel.numberOfLines = 0
            cfrLabel.font = .preferredFont(forTextStyle: .footnote)
            cfrLabel.textColor = UIColor.cfr


            let stackView   = UIStackView()
            stackView.axis  = NSLayoutConstraint.Axis.vertical
            stackView.distribution  = UIStackView.Distribution.equalSpacing
            stackView.alignment = UIStackView.Alignment.leading
            
            stackView.addArrangedSubview(confirmedLabel)
            stackView.addArrangedSubview(deathsLabel)
            stackView.addArrangedSubview(cfrLabel)

            stackView.translatesAutoresizingMaskIntoConstraints = false

            self.detailCalloutAccessoryView = stackView
            
            canShowCallout = true
            let mapIcon = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            mapIcon.setBackgroundImage(UIImage(systemName: "waveform.path.ecg"), for: UIControl.State())
            rightCalloutAccessoryView = mapIcon
        }
    }
}
