// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import Foundation

protocol CalculationResultDelegate: AnyObject {
    func calcReady(age: Float, new10YrRisk: Float, new10YrOptimalRisk: Float, lifeCal: Float, lifeCalOptimal: Float)
}

enum InputType: String {
    case number = "number"
    case toggle = "toggle"
    
    /// More intuitively named getter for `rawValue`.
    var id: String { rawValue }
    
    /// The UI friendly name of the `AuthProvider`. Used for display.
    var name: String {
        switch self {
        case .number:
            return "number"
        case .toggle:
            return "toggle"
        }
    }
    
    /// Failable initializer to create an `AuthProvider` from it's corresponding `name` value.
    /// - Parameter rawValue: String value representing `AuthProvider`'s name or type.
    init?(rawValue: String) {
        switch rawValue {
        case "number":
            self = .number
        case "toggle":
            self = .toggle
        default: return nil
        }
    }
}

struct Input {
    var label: String;
    var placeholder: String?;
    var type: InputType;
    var validation: CGFunction?;
    var stack: UIStackView?;
    var input: Any?;
}

/// Login View presented when peforming Email & Password Login Flow
class SurveyView: UIView {
    weak var delegate: CalculationResultDelegate? = nil
    
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
        vs.alignment = .top
        vs.distribution = .equalCentering
        vs.translatesAutoresizingMaskIntoConstraints = false
        vs.spacing = 25
        
        return vs;
    }()
    
    var verticalStack: UIStackView = {
        let vs = UIStackView()
        vs.axis = .vertical
        vs.alignment = .fill
        vs.distribution = .fill
        vs.translatesAutoresizingMaskIntoConstraints = false
        vs.spacing = 25
        
        return vs;
    }()
    
    var ageTF: UITextField?
    var hdlTF: UITextField?
    var totalHdlTF: UITextField?
    var sbpTF: UITextField?
    var maleSW: UISwitch?
    var diabetesSW: UISwitch?
    var treatmentSW: UISwitch?
    var smokerSW: UISwitch?
    
    lazy var calculateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Calculate", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.highlightedLabel, for: .highlighted)
        button.backgroundColor = UIColor(hex: 0x00C28D)
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(calculate), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(frame: .zero)
        
        ageTF = buildNumberInput(placeholder: "20-79")
        hdlTF = buildNumberInput(placeholder: "20-100")
        totalHdlTF = buildNumberInput(placeholder: "130-320")
        sbpTF = buildNumberInput(placeholder: "90-200")
        
        maleSW = buildSwitch(placeholder: "Male?")
        diabetesSW = buildSwitch(placeholder: "Diabetes?")
        treatmentSW = buildSwitch(placeholder: "Treatment for Hypertension?")
        smokerSW = buildSwitch(placeholder: "Smoker?")
        
        setupSubviews()
    }
    
    private func buildAlert (msg: String) {
        let alert = UIAlertController(title: "Invalid Form", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.window?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    @objc private func calculate() {
        var dtbChoice = diabetesSW?.isOn
        var smkChoice = smokerSW?.isOn
        var hypChoice = treatmentSW?.isOn
        var gender = maleSW?.isOn
        var race = "White"
        var age = ageTF?.text
        var hdl = hdlTF?.text
        var totalChol = totalHdlTF?.text
        var sbp = sbpTF?.text
        
        for field in [age, hdl, totalChol, sbp] {
            if field == "" {
                buildAlert(msg: "Please fill in the form properly")
                return
            }
        }
        
        if Float(age!)! < 20 || Float(age!)! > 79 {
            buildAlert(msg: "Age must be between 20-79")
            return
        }
        if Float(hdl!)! < 20 || Float(hdl!)! > 100 {
            buildAlert(msg: "HDL Cholesterol (mg/dL) must be between 20-100")
            return
        }
        if Float(totalChol!)! < 130 || Float(totalChol!)! > 320 {
            buildAlert(msg: "Total Cholesterol (mg/dL) must be between 130-320")
            return
        }
        if Float(sbp!)! < 90 || Float(sbp!)! > 200 {
            buildAlert(msg: "Systolic Blood Pressure (mm Hg) must be between 90-200")
            return
        }
        
        var newCoeff = race + (gender! ? "Male" : "Female") // WhiteMale, BlackMale, WhiteFemale, or BlackFemale
        var new10YrRisk: Float? = nil
        var new10YrOptimalRisk: Float? = nil
        var lifeCal: Float? = nil
        var lifeCalOptimalRisk: Float? = nil
        
        if (dtbChoice!) {
            dtbChoice = true
            //console.log('dtbChoice= ' + dtbChoice);
        } else {
            dtbChoice = false
            //console.log('dtbChoice= ' + dtbChoice);
        };
        
        if (smkChoice!) {
            smkChoice = true
            //console.log('smkChoice= ' + smkChoice);
        } else {
            smkChoice = false
            //console.log('smkChoice= ' + smkChoice);
        };
        
        if (hypChoice!) {
            hypChoice = true
            //console.log('hypChoice= ' + hypChoice);
        } else {
            hypChoice = false
            //console.log('hypChoice= ' + hypChoice);
        };
        
        switch (newCoeff) {
        case "WhiteMale":
            new10YrRisk = round(Calculate10YrRisk(coeff: Gender(type: "WhiteMale"), age: Float(age!)!, TC: Float(totalChol!)!, HDL: Float(hdl!)!, SBP: Float(sbp!)!, BPTreatment: hypChoice!, DM: dtbChoice!, Smoker: smkChoice!) * 1000) / 10
            new10YrOptimalRisk = round(Calculate10YrRisk(coeff: Gender(type: "WhiteMale"), age: Float(age!)!, TC: 170, HDL: 50, SBP: 110, BPTreatment: false, DM: false, Smoker: false) * 1000) / 10
            break;
        case "WhiteFemale":
            new10YrRisk = round(Calculate10YrRisk(coeff: Gender(type: "WhiteFemale"), age: Float(age!)!, TC: Float(totalChol!)!, HDL: Float(hdl!)!, SBP: Float(sbp!)!, BPTreatment: hypChoice!, DM: dtbChoice!, Smoker: smkChoice!) * 1000) / 10
            new10YrOptimalRisk = round(Calculate10YrRisk(coeff: Gender(type: "WhiteFemale"), age: Float(age!)!, TC: 170, HDL: 50, SBP: 110, BPTreatment: false, DM: false, Smoker: false) * 1000) / 10
           break;
        default:
            return
        }
        
        lifeCal = round(ASCVD_LifetimeRisk(TC: Float(totalChol!)!, SBP: Float(sbp!)!, BPTreatment: hypChoice!, DM: dtbChoice!,Smoker: smkChoice!,gender: gender!).Point! * 1000) / 10
        lifeCalOptimalRisk = round(ASCVD_LifetimeRisk(TC: 170, SBP: 110,BPTreatment: false, DM: false, Smoker: false , gender: gender!).Point! * 1000) / 10
        //console.log(lifeCal);
        
        delegate?.calcReady(age: Float(age!)!, new10YrRisk: new10YrRisk!, new10YrOptimalRisk: new10YrOptimalRisk!, lifeCal: lifeCal!, lifeCalOptimal: lifeCalOptimalRisk!)
    }
    
    // MARK: - Subviews Setup
    
    private func buildNumberInput(placeholder: String) -> UITextField {
        let textField = UITextField()
        
        textField.backgroundColor = UIColor(hex: 0x1E1E1E)
        textField.textColor = UIColor(hex: 0x17ECB2)
        textField.keyboardType = .numberPad
        
        textField.layer.cornerRadius = 14
        textField.layer.borderColor = UIColor(hex: 0x17ECB2).cgColor
        textField.layer.borderWidth = 1
        textField.minimumFontSize = 16
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x01654F)]
        )
        
        return textField
    }
    
    private func buildSwitch(placeholder: String) -> UISwitch {
        let switchfield = UISwitch()
        
        switchfield.backgroundColor = UIColor(hex: 0x1E1E1E)
        switchfield.isOn = false
        
        return switchfield
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
        
        primaryStack.addArrangedSubview(verticalStack)
        
        let numberInputs = [["Age", ageTF!], ["HDL Cholesterol (mg/dL)", hdlTF!], ["Total Cholesterol (mg/dL)", totalHdlTF], ["Systolic Blood Pressure (mm Hg)", sbpTF]]
        
        for numberInput in numberInputs {
            let label = UILabel()
            let vs = UIStackView()
            
            vs.spacing = 10
            vs.axis = .vertical
            vs.translatesAutoresizingMaskIntoConstraints = false
            
            label.text = (numberInput[0] as! String)
            label.textAlignment = .left
            label.textColor = UIColor(hex: 0x17ECB2)
            label.backgroundColor = .clear
            label.translatesAutoresizingMaskIntoConstraints = false
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.numberOfLines = 0
            
            let input = numberInput[1] as! UIView
            
            vs.addArrangedSubview(label)
            vs.addArrangedSubview(input)
            
            verticalStack.addArrangedSubview(vs)
            
            NSLayoutConstraint.activate([
                vs.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: 15
                ),
                vs.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -15
                ),
                vs.heightAnchor.constraint(equalToConstant: 60),
                input.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        let switchInputs = [["Male?", maleSW!], ["Diabetes?", diabetesSW!], ["Treatment for Hypertension", treatmentSW], ["Smoker?", smokerSW]]
        
        for switchInput in switchInputs {
            let label = UILabel()
            let vs = UIStackView()
            
            vs.spacing = 10
            vs.axis  = .horizontal
            vs.alignment = .center
            vs.translatesAutoresizingMaskIntoConstraints = false
            
            label.text = (switchInput[0] as! String)
            label.textAlignment = .left
            label.textColor = UIColor(hex: 0x17ECB2)
            label.backgroundColor = .clear
            label.translatesAutoresizingMaskIntoConstraints = false
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.numberOfLines = 0
            
            vs.addArrangedSubview(label)
            vs.addArrangedSubview(switchInput[1] as! UIView)
            
            verticalStack.addArrangedSubview(vs)
            
            NSLayoutConstraint.activate([
                vs.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: 15
                ),
                vs.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -15
                ),
                vs.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        primaryStack.addArrangedSubview(calculateButton)
        
        calculateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calculateButton.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor,
                constant: 15
            ),
            calculateButton.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor,
                constant: -15
            ),
        ])
    }
    
    
    private func Calculate10YrRisk(coeff: Gender, age: Float, TC: Float, HDL: Float, SBP: Float, BPTreatment: Bool, DM: Bool, Smoker: Bool) -> Float {
        var sum: Float = 0;
        sum += log(age) * coeff.Age!;
        sum += pow(log(age), 2) * coeff.AgeSquared!;
        sum += log(TC) * coeff.TC!;
        sum += log(age) * log(TC) * coeff.AgexTC!;
        sum += log(HDL) * coeff.HDL!;
        sum += log(age) * log(HDL) * coeff.AgexHDL!;
        
        if (BPTreatment) {
            sum += log(SBP) * coeff.TreatedBP!;
            sum += log(age) * log(SBP) * coeff.AgexTreatedBP!;
        } else {
            //No BP treatment
            sum += log(SBP) * coeff.UntreatedBP!;
            sum += log(age) * log(SBP) * coeff.AgexUntreatedBP!;
        }
        
        sum += (Smoker ? 1 : 0) * coeff.Smoker!;
        sum +=  (Smoker ? 1 : 0) * log(age) * coeff.AgexSmoker!;
        sum +=  (DM ? 1 : 0) * coeff.Diabetes!;
        
        return 1 - pow(coeff.BaselineSurvival!, pow(2.7, sum - coeff.OverallMean!));
    }
    
    /*
     USAGE
     TC = total cholesterol (mg/dL) [optimal: 170]
     SBP = systolic blood pressure (mmHg) [optimal: 110]
     BPTreatment -> 1=yes (patient is receiving medications for hypertension), 0=no [optimal: 0]
     DM -> 1=yes (the patient is a diabetic), 0=no [optimal: 0]
     Smoker -> 1=yes (the patient is a smoker), 0=no [optimal: 0]
     Gender -> 1=male, 2=female
     */
    func ASCVD_LifetimeRisk(TC: Float, SBP: Float, BPTreatment: Bool, DM: Bool, Smoker: Bool, gender: Bool) -> ConfidenceInterval {
        var Optimal = 0;
        var Suboptimal = 0;
        var Elevated = 0;
        var Major = 0;
        
        if (TC >= 240) {
            Major += 1;
        } else if ((TC >= 200) && (TC <= 239)) {
            Elevated += 1;
        } else if ((TC >= 180) && (TC <= 199)) {
            Suboptimal += 1;
        } else {
            Optimal += 1;
        }
        
        if (BPTreatment) {
            Major += 1;
        } else {
            // Untreated BP
            if (SBP >= 160) {
                Major += 1;
            } else if ((SBP >= 140) && (SBP <= 159)) {
                Elevated += 1;
            } else if ((SBP >= 120) && (SBP <= 139)) {
                Suboptimal += 1;
            } else {
                Optimal += 1;
            }
        }
        
        if (DM) { Major += 1; }
        if (Smoker) { Major += 1; }
        
        //Count up the risk factors...
        if (Major >= 2) {
            // Male
            if (gender) { return ConfidenceInterval(point: 0.69, low: 0.62, high: 0.73); }
            // Femate
            if (!gender) { return ConfidenceInterval(point: 0.5, low: 0.45, high: 0.56); }
        }
        if (Major == 1) {
            if (gender) { return ConfidenceInterval(point: 0.5, low: 0.46, high: 0.55); }
            if (!gender) { return ConfidenceInterval(point: 0.39, low: 0.35, high: 0.43); }
        }
        if (Elevated >= 1) {
            if (gender) { return  ConfidenceInterval(point:0.46, low:0.38, high:0.53); }
            if (!gender) { return ConfidenceInterval(point:0.39, low:0.33, high:0.45); }
        }
        if (Suboptimal >= 1) {
            if (gender) { return  ConfidenceInterval(point:0.36, low:0.23, high:0.5); }
            if (!gender) { return  ConfidenceInterval(point:0.27, low:0.18, high:0.36); }
        }
        
        //All risk factors are 'optimal'...
        if (gender) { return  ConfidenceInterval(point:0.05, low:0, high:0.12); }
        return ConfidenceInterval(point:0.08, low:0, high:0.22); //If Gender = GenderEnum.Female Then
    }
}
