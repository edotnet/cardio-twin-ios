//
//  Genders.swift
//  AuthenticationExample
//
//  Created by edik on 04.09.22.
//  Copyright © 2022 Firebase. All rights reserved.
//

import Foundation

class Gender {
    var Age: Float?
    var AgeSquared: Float?
    var TC: Float?
    var AgexTC: Float?
    var HDL: Float?
    var AgexHDL: Float?
    var TreatedBP: Float?
    var AgexTreatedBP: Float?
    var UntreatedBP: Float?
    var AgexUntreatedBP: Float?
    var Smoker: Float?
    var AgexSmoker: Float?
    var Diabetes: Float?
    var BaselineSurvival: Float?
    var OverallMean: Float?
    
    init(type: String) {
        if type == "WhiteFemale" {
            Age = -29.799;
            AgeSquared = 4.884;
            TC = 13.54;
            AgexTC = -3.114;
            HDL = -13.578;
            AgexHDL = 3.149;
            TreatedBP = 2.019;
            AgexTreatedBP = 0;
            UntreatedBP = 1.957;
            AgexUntreatedBP = 0;
            Smoker = 7.574;
            AgexSmoker = -1.665;
            Diabetes = 0.661;
            BaselineSurvival = 0.96652;
            OverallMean = -29.1817;
        } else if (type == "WhiteMale"){
            Age = 12.344;
            AgeSquared = 0;
            TC = 11.853;
            AgexTC = -2.664;
            HDL = -7.99;
            AgexHDL = 1.769;
            TreatedBP = 1.797;
            AgexTreatedBP = 0;
            UntreatedBP = 1.764;
            AgexUntreatedBP = 0;
            Smoker = 7.837;
            AgexSmoker = -1.795;
            Diabetes = 0.658;
            BaselineSurvival = 0.91436;
            OverallMean = 61.1816;
        }
    }
}
