//
//  MainDisplayViewModel.swift
//  GroupProject
//
//  Created by Volodya on 17.12.2024.
//

import Foundation

class viewModel {
    private(set) var tasks: [MainDisplay] = []
    
    var reloadTableView: (() -> Void)?
    
    private let key = "tasks"

    init() {
        loadTasks()
    }
    
    func addTask(title: String, priority: TaskPriority) {
        let newTask = MainDisplay(title: title, priority: priority, isCompleted: false)
        tasks.append(newTask)
        saveTasks()
        reloadTableView?()
    }
    
    func isComplete(at index: Int) {
        tasks[index].isCompleted.toggle()
        saveTasks()
        reloadTableView?()
    }
    
    func deleteTask(at index: Int) {
        tasks.remove(at: index)
        saveTasks()
        reloadTableView?()
    }
    
    func editTask(at index: Int, newTitle: String, newPriority: TaskPriority) {
        tasks[index].title = newTitle
        tasks[index].priority = newPriority
        saveTasks()
        reloadTableView?()
    }
    
    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: key),
           let savedTasks = try? JSONDecoder().decode([MainDisplay].self, from: data) {
            tasks = savedTasks
        }
    }
}
