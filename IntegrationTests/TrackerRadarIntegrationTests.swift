//
//  TrackerRadarIntegrationTests.swift
//  AtbIntegrationTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import XCTest
import TrackerRadarKit
import DuckDuckGo
import PrivacyDashboard
@testable import BrowserServicesKit
@testable import Core

class TrackerRadarIntegrationTests: XCTestCase {

    func test() throws {

        let url = AppUrls(statisticsStore: MockStatisticsStore()).trackerDataSet
        let data = try Data(contentsOf: url)
        let dataManager = TrackerDataManager(etag: UUID().uuidString,
                                             data: data,
                                             embeddedDataProvider: AppTrackerDataSetProvider())

        dataManager.assertIsMajorTracker(domain: "google.com")
        dataManager.assertIsMajorTracker(domain: "facebook.com")
        dataManager.assertEntityAndDomainLookups()
        dataManager.assertEntitiesHaveNames()

    }

}

extension TrackerDataManager {

    func assertIsMajorTracker(domain: String, file: StaticString = #file, line: UInt = #line) {
        guard let tds = fetchedData?.tds else {
            XCTFail("No TDS found")
            return
        }
        
        let entity = tds.findEntity(forHost: domain)
        XCTAssertNotNil(entity, "no entity found for domain \(domain)", file: file, line: line)
        XCTAssertGreaterThan(entity?.prevalence ?? 0, TrackerInfo.Constants.majorNetworkPrevalence, file: file, line: line)
    }

    func assertEntityAndDomainLookups(file: StaticString = #file, line: UInt = #line) {
        guard let tds = fetchedData?.tds else {
            XCTFail("No TDS found")
            return
        }
        
        tds.domains.forEach { domain, entityName in
            let entityFromHost = tds.findEntity(forHost: domain)
            let entityFromName = tds.findEntity(byName: entityName)
            XCTAssertNotNil(entityFromHost, file: file, line: line)
            XCTAssertNotNil(entityFromName, file: file, line: line)
            XCTAssertEqual(entityFromHost, entityFromName, file: file, line: line)
        }
    }

    func assertEntitiesHaveNames(file: StaticString = #file, line: UInt = #line) {
        trackerData.entities.keys.forEach { entityName in
            XCTAssertNotNil(entityName, file: file, line: line)
            XCTAssertNotEqual("", entityName, file: file, line: line)
        }
    }

}
