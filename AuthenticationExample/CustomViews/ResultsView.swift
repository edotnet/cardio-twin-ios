//
//  Processing.swift
//  AuthenticationExample
//
//  Created by edik on 04.09.22.
//  Copyright © 2022 Firebase. All rights reserved.
//

import SwiftUI
import FirebaseDatabase

class ResultsView: UIView {
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layoutMargins = .zero
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    var primaryStack: UIStackView = {
        let vs = UIStackView()
        vs.axis = .vertical
        vs.alignment = .leading
        vs.distribution = .equalSpacing
        vs.translatesAutoresizingMaskIntoConstraints = false
        vs.spacing = 25
        
        return vs;
    }()
    
    var Age: Float?
    var New10YrRisk: Float?
    var New10YrOptimalRisk: Float?
    var LifeCal: Float?
    var LifeCalOptimal: Float?
    
    convenience init(age: Float, new10YrRisk: Float, new10YrOptimalRisk: Float, lifeCal: Float, lifeCalOptimal: Float) {
        self.init(frame: .zero)
        
        Age = age
        New10YrRisk = new10YrRisk
        New10YrOptimalRisk = new10YrOptimalRisk
        LifeCal = lifeCal
        LifeCalOptimal = lifeCalOptimal
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(scrollView)
        
        scrollView.addSubview(primaryStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            primaryStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            primaryStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            primaryStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            primaryStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            primaryStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // primaryStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        primaryStack.spacing = 25
        
        let title = buildShowItem(placeholder: "10 Year ASCVD Risk")
        title.font = title.font.withSize(30)
        
        primaryStack.addArrangedSubview(title)
        
        if Age! >= 40 {
            primaryStack.addArrangedSubview(buildShowItem(placeholder: "Risk - \(New10YrRisk ?? 0)%"))
            primaryStack.addArrangedSubview(buildShowItem(placeholder: "With Optimal Risk Factors - \(New10YrOptimalRisk ?? 0)%"))
        } else {
            let label = buildShowItem(placeholder: "The 10-year risk calculator only provides 10-year risk estimates for individuals aged 40 to 79 years.")
            label.textColor = UIColor.white
            
            primaryStack.addArrangedSubview(label)
        }

        
        let title2 = buildShowItem(placeholder: "Lifetime ASCVD Risk")
        title2.font = title2.font.withSize(30)
        
        primaryStack.addArrangedSubview(title2)
        
        if Age! <= 59 {
            primaryStack.addArrangedSubview(buildShowItem(placeholder: "Risk - \(LifeCal ?? 0)%"))
            primaryStack.addArrangedSubview(buildShowItem(placeholder: "With Optimal Risk Factors - \(LifeCalOptimal ?? 0)%"))
        } else {
            let label = buildShowItem(placeholder: "The lifetime risk calculator only provides lifetime risk estimates for individuals aged 20 to 59 years.")
            label.textColor = UIColor.white
            
            primaryStack.addArrangedSubview(label)
        }
        
    }
    
    private func buildShowItem (placeholder: String) -> UILabel {
        let label = UILabel()
        
        label.text = placeholder
        label.textAlignment = .left
        label.textColor = UIColor(hex: 0x17ECB2)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        
        return label
    }
}
