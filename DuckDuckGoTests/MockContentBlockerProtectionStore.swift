//
//  MockContentBlockerProtectionStore.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

@testable import Core

class MockContentBlockerProtectionStore: ContentBlockerProtectionStore {

    var unprotectedDomains = Set<String>()
    var tempUnprotectedDomains = [String]()
    var protecting = true
    var enabled = true

    func isProtected(domain: String?) -> Bool {
        guard let domain = domain else { return true }
        return unprotectedDomains.contains(domain)
    }
    
    func isTempUnprotected(domain: String?) -> Bool {
        guard let domain = domain else { return false }
        return tempUnprotectedDomains.contains(domain)
    }

    func disableProtection(forDomain domain: String) {
        unprotectedDomains.insert(domain)
    }

    func enableProtection(forDomain domain: String) {
        unprotectedDomains.remove(domain)
    }
}
