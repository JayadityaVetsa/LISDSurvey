//
//  LISDSurveyApp.swift
//  LISDSurvey
//
//  Created by Jayaditya_Vetsa on 4/28/25.
//

import SwiftUI

@main
struct LISDSurveyApp: App {
    @StateObject private var surveyStore = SurveyStore()
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(surveyStore)
        }
    }
}
