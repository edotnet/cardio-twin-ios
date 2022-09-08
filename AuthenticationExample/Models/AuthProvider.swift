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

/// Firebase Auth supported identity providers and other methods of authentication
enum AuthProvider: String {
  case google = "google.com"
  case facebook = "facebook.com"
  case apple = "apple.com"
  
  /// More intuitively named getter for `rawValue`.
  var id: String { rawValue }

  /// The UI friendly name of the `AuthProvider`. Used for display.
  var name: String {
    switch self {
    case .google:
      return "Google"
    case .facebook:
      return "Facebook"
    case .apple:
      return "Apple"
    }
  }

  /// Failable initializer to create an `AuthProvider` from it's corresponding `name` value.
  /// - Parameter rawValue: String value representing `AuthProvider`'s name or type.
  init?(rawValue: String) {
    switch rawValue {
    case "Google":
      self = .google
    case "Facebook":
      self = .facebook
    case "Apple":
      self = .apple
    default: return nil
    }
  }
}

// MARK: DataSourceProvidable

extension AuthProvider: DataSourceProvidable {
  private static var providers: [AuthProvider] {
    [.google, .facebook]
  }

  static var providerSection: Section {
    let providers = self.providers.map { Item(title: $0.name, textColor: UIColor(hex: 0x17ECB2)) }
    let header = "Identity Providers"
    let footer = ""
    return Section(headerDescription: header, footerDescription: footer, items: providers)
  }
  
  static var sections: [Section] {
    [providerSection]
  }

  static var authLinkSections: [Section] {
    let allItems = AuthProvider.sections.flatMap { $0.items }
    let header = "Manage linking between providers"
    let footer =
      "Select an unchecked row to link the currently signed in user to that auth provider. To unlink the user from a linked provider, select its corresponding row marked with a checkmark."
    return [Section(headerDescription: header, footerDescription: footer, items: allItems)]
  }

  var sections: [Section] { AuthProvider.sections }
}
