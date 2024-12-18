import UIKit

class ViewController: UIViewController {
    
    private let showViewModel = viewModel()
    private let tableView = UITableView()
    private let buttons = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        UI()
        Bindings()
    }
    
    private func UI() {
        view.addSubview(tableView)
        view.addSubview(buttons)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Task")
        
        buttons.translatesAutoresizingMaskIntoConstraints = false
        buttons.setTitle("Add Task", for: .normal)
        buttons.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            buttons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            buttons.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func Bindings() {
        showViewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func addTask() {
        let alert = UIAlertController(title: "New Task", message: "Enter the task to do:", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Task Title" }
        
        for priority in TaskPriority.allCases {
            alert.addAction(UIAlertAction(title: priority.rawValue, style: .default) { _ in
                if let title = alert.textFields?.first?.text, !title.isEmpty {
                    self.showViewModel.addTask(title: title, priority: priority)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showViewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Task", for: indexPath)
        let task = showViewModel.tasks[indexPath.row]
        cell.textLabel?.text = "\(task.title) | \(task.priority.rawValue) | \(task.isCompleted ? "✅" : "❌")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = showViewModel.tasks[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Task", message: "Edit this task:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        for priority in TaskPriority.allCases {
            alert.addAction(UIAlertAction(title: priority.rawValue, style: .default) { _ in
                if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                    self.showViewModel.editTask(at: indexPath.row, newTitle: newTitle, newPriority: priority)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showViewModel.deleteTask(at: indexPath.row)
        }
    }
}
