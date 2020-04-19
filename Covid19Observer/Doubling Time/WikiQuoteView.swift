//
//  WikiQuoteView.swift
//  Doubling
//
//  Created by Igor Malyarov on 17.03.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct WikiQuoteView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The doubling time is time it takes for a population to double in size/value. It is applied to population growth, inflation, resource extraction, consumption of goods, compound interest, the volume of malignant tumours, and many other things that tend to grow over time. When the relative growth rate (not the absolute growth rate) is constant, the quantity undergoes exponential growth and has a constant doubling time or period.")
            
            Text("The notion of doubling time dates to interest on loans in Babylonian mathematics. Clay tablets from circa 2000 BCE include the exercise \"Given an interest rate of 1/60 per month (no compounding), come the doubling time.\" This yields an annual interest rate of 12/60 = 20%, and hence a doubling time of 100% growth/20% growth per year = 5 years. Further, repaying double the initial amount of a loan, after a fixed time, was common commercial practice of the period: a common Assyrian loan of 1900 BCE consisted of loaning 2 minas of gold, getting back 4 in five years, and an Egyptian proverb of the time was \"If wealth is placed where it bears interest, it comes back to you redoubled.\"")
            
            Text("— Wikipedia")
                .foregroundColor(.secondary)
//                .font(.subheadline)
            
//            Spacer()
        }
        .foregroundColor(.secondary)
        .font(.footnote)
        .padding()
    }
}

struct WikiQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        WikiQuoteView()
    }
}
