//
//  SyncView.swift
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

import SwiftUI
import DDGSync

@available(iOS 14, *)
struct SyncView: View {
    
    @ObservedObject var model = SyncModel(sync: DDGSync(), deviceName: UIDevice.current.name)
    
    var body: some View {
        VStack(spacing: 12) {
            
            Group {
                Spacer()
                
                Text("Sync Authenticated")
                
                Spacer()
                
                // TODO QR code to connect another device
                QRCodeView(data: model.recoveryCode, size: 192)
                
                Spacer()
                
                Button("Fetch Now") {
                    model.fetchNow()
                }
                
                Spacer()
                
                Button("Disconnect") {
                    model.disconnect()
                }
            }.visibility(model.isAuthenticated ? .visible : .gone)
            
        
            Group {
                Text("Device: \(model.deviceName)")

                Button("Create account") {
                    model.createAccount()
                }
                .disabled(model.isBusy)
                        
                CodeScannerView(isScanning: $model.isScanning,
                                scannedCode: $model.scannedCode)
                        
                Button("Scan Code") {
                    model.startScanning()
                }
                .disabled(model.isBusy)
                
                SwiftUI.ProgressView()
                    .visibility(model.isBusy ? .visible : .invisible)

            }.visibility(model.isAuthenticated ? .gone : .visible)
                
        }.sheet(isPresented: $model.showErrorMessage) {
            Text(model.errorMessage)
                .font(.caption)
                .foregroundColor(.red)
        }
    }
    
}

struct CodeScannerView: View {
    
    @Binding var isScanning: Bool
    @Binding var scannedCode: Data
    
    var body: some View {
        VStack {
            Text("Code scanner will appear here")
        }
        .frame(width: 300, height: 300)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
}

struct QRCodeView: View {
    
    let data: Data
    let size: Int
 
    var body: some View {
        VStack {
            Text("QRCode will appear here")
        }
        .frame(width: 150, height: 150)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
}
