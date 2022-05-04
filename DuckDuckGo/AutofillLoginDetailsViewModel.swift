//
//  AutofillLoginDetailsViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import BrowserServicesKit
import SwiftUI

protocol AutofillLoginDetailsViewModelDelegate: AnyObject {
    func autofillLoginDetailsViewModelDidSave()
}


final class AutofillLoginDetailsViewModel: ObservableObject {
    enum ViewMode {
        case edit
        case view
    }
    
    enum PasteboardCopyAction {
        case username
        case password
        case address
    }
    
    weak var delegate: AutofillLoginDetailsViewModelDelegate?
    let account: SecureVaultModels.WebsiteAccount
    @Published var username = ""
    @Published var password = ""
    @Published var address = ""
    @Published var title = ""
    @Published var viewMode: ViewMode = .view
    
    internal init(account: SecureVaultModels.WebsiteAccount) {
        self.account = account
        self.username = account.username
        self.address = account.domain
        self.title = account.title ?? ""
        setupPassword(with: account)
    }
    
    func toggleEditMode() {
        withAnimation {
            if viewMode == .edit {
                viewMode = .view
            } else {
                viewMode = .edit
            }
        }
    }
    
    func copyToPasteboard(_ action: PasteboardCopyAction) {
        switch action {
        case .username:
            UIPasteboard.general.string = username
        case .password:
            UIPasteboard.general.string = "123"
        case .address:
            UIPasteboard.general.string = address
        }
    }
    
    #warning("Refactor, copied from SaveLoginViewModel")
    var hiddenPassword: String {
         let maximumPasswordDisplayCount = 40

        // swiftlint:disable:next line_length
        let passwordCount = password.count > maximumPasswordDisplayCount ? maximumPasswordDisplayCount : password.count
        return String(repeating: "•", count: passwordCount)
    }
    
    
    private func setupPassword(with account: SecureVaultModels.WebsiteAccount) {
        do {
            if let accountID = account.id {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                                                                 
                if let credential = try
                    vault.websiteCredentialsFor(accountId: accountID) {
                    self.password = String(data: credential.password, encoding: .utf8) ?? ""
                }
            }
            
        } catch {
            print("Can't retrieve password")
        }
        
    }
    
    func save() {
        do {
            if let accountID = account.id {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                                                                 
                if var credential = try vault.websiteCredentialsFor(accountId: accountID) {
                    credential.account.username = username
                    credential.account.title = title
                    credential.account.domain = address
                    credential.password = password.data(using: .utf8)!
                    
                    try vault.storeWebsiteCredentials(credential)
                    delegate?.autofillLoginDetailsViewModelDidSave()
                }
            }
            
        } catch {
            
        }
    }
}
