//
//  MainDisplay.swift
//  GroupProject
//
//  Created by Volodya on 17.12.2024.
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct MainDisplay: Codable {
    var title: String
    var priority: TaskPriority
    var isCompleted: Bool
}
