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
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class SurveyViewController: UIViewController, CalculationResultDelegate {
    var dataSourceProvider: DataSourceProvider<User>!
    
    var userImage = UIImageView(systemImageName: "person.circle.fill", tintColor: .secondaryLabel)
    
    private var _user: User?
    var user: User? {
        get { _user ?? Auth.auth().currentUser }
        set { _user = newValue }
    }
    
    /// Init allows for injecting a `User` instance during UI Testing
    /// - Parameter user: A Firebase User instance
    init(_ user: User? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Life Cycle
    
    override func loadView() {
       let sv = SurveyView()
        sv.delegate = self;
        view = sv
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureView()
        
        view.backgroundColor = UIColor(hex: 0x1E1E1E)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserImage()
    }
    
    
    // MARK: - Firebase 🔥
    
    public func signCurrentUserOut() {
        try? Auth.auth().signOut()
        updateUI()
    }
    
    // MARK: - Private Helpers
    
    private func configureNavigationBar() {
        navigationItem.title = "ASCVD Test"
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.prefersLargeTitles = true
        
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor(hex: 0x17ECB2)]
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor(hex: 0x17ECB2)]
        navigationBar.addProfilePic(userImage)
    }
    
    private func configureView() {
        self.view.backgroundColor = UIColor(hex: 0x1e1e1e)
        self.view.tintColor = UIColor(hex: 0x17ECB2)
    }
    
    private func updateUserImage() {
        guard let photoURL = user?.photoURL else {
            let defaultImage = UIImage(systemName: "person.circle.fill")
            userImage.image = defaultImage?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
            return
        }
        userImage.setImage(from: photoURL)
    }
    
    private func updateUI() {
        updateUserImage()
    }
    
    private func animateUpdates(for tableView: UITableView) {
        UIView.transition(with: tableView, duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { tableView.reloadData() })
    }
    
    private var originalOffset: CGFloat?
    
    private func adjustUserImageAlpha(_ offset: CGFloat) {
        originalOffset = originalOffset ?? offset
        let verticalOffset = offset - originalOffset!
        userImage.alpha = 1 - (verticalOffset * 0.05)
    }
    
    func calcReady(age: Float, new10YrRisk: Float, new10YrOptimalRisk: Float, lifeCal: Float, lifeCalOptimal: Float) {
        navigationItem.title = "ASCVD Results"
        view = ResultsView(age: age, new10YrRisk: new10YrRisk, new10YrOptimalRisk: new10YrOptimalRisk, lifeCal: lifeCal, lifeCalOptimal: lifeCalOptimal)
        view.backgroundColor = UIColor(hex: 0x1E1E1E)

      let ref = Database.database().reference()
    ref.child("results/\(Auth.auth().currentUser?.uid)").setValue(["age": age, "new10YrRisk": new10YrRisk, "new10YrOptimalRisk": new10YrOptimalRisk, "lifeCal": lifeCal, "lifeCalOptimal": lifeCalOptimal])
    }
}
