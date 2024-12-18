import UIKit
import SnapKit

class TaskViewController: UIViewController {
    private let viewModel = MainDisplayViewModel()
    private let tableView = UITableView()
    private let inputField = UITextField()
    private let addButton = UIButton(type: .system)
    private let separatorView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        bindViewModel()
        hideKeyboardWhenTappedAround()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Task List"

        inputField.placeholder = "Add new task..."
        inputField.borderStyle = .none
        inputField.backgroundColor = UIColor.systemGray6
        inputField.layer.cornerRadius = 8
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        inputField.leftViewMode = .always
        view.addSubview(inputField)

        inputField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-80)
            make.height.equalTo(40)
        }

        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(showPrioritySelector), for: .touchUpInside)
        view.addSubview(addButton)

        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(inputField)
            make.leading.equalTo(inputField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }

        separatorView.backgroundColor = .systemGray4
        view.addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(inputField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        view.addSubview(tableView)
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .systemGray6
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func configureTableView() {
        tableView.rowHeight = 60
    }

    private func bindViewModel() {
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    @objc private func showPrioritySelector() {
        guard let taskName = inputField.text, !taskName.isEmpty else { return }
        let alert = UIAlertController(title: "Select Priority", message: "Choose task priority", preferredStyle: .actionSheet)
        
        for priority in TaskPriority.allCases {
            alert.addAction(UIAlertAction(title: priority.rawValue, style: .default, handler: { _ in
                self.viewModel.addTask(title: taskName, priority: priority)
                self.inputField.text = ""
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showEditTaskAlert(for index: Int) {
        let task = viewModel.tasks[index]
        let alert = UIAlertController(title: "Edit Task", message: "Modify task and priority", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        for priority in TaskPriority.allCases {
            alert.addAction(UIAlertAction(title: priority.rawValue, style: .default) { _ in
                if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                    self.viewModel.editTask(at: index, newTitle: newTitle, newPriority: priority)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let toDoCount = viewModel.tasks.filter { !$0.isCompleted }.count
        let doneCount = viewModel.tasks.filter { $0.isCompleted }.count
        return section == 0 ? "To-Do (\(toDoCount))" : "Done (\(doneCount))"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.filter { $0.isCompleted == (section == 1) }.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let filteredTasks = viewModel.tasks.filter { $0.isCompleted == (indexPath.section == 1) }
        let task = filteredTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(task.title) | \(task.priority.rawValue)"
        content.secondaryText = task.isCompleted ? "✅ Done" : "❌ To-Do"
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let filteredTasks = viewModel.tasks.filter { $0.isCompleted == (indexPath.section == 1) }
        let task = filteredTasks[indexPath.row]
        
        let toggleAction = UIContextualAction(style: .normal, title: "Toggle") { [weak self] _, _, completion in
            if let index = self?.viewModel.tasks.firstIndex(where: { $0.title == task.title }) {
                self?.viewModel.isComplete(at: index)
            }
            completion(true)
        }
        toggleAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [toggleAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filteredTasks = viewModel.tasks.filter { $0.isCompleted == (indexPath.section == 1) }
        if let index = viewModel.tasks.firstIndex(where: { $0.title == filteredTasks[indexPath.row].title }) {
            showEditTaskAlert(for: index)
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let filteredTasks = viewModel.tasks.filter { $0.isCompleted == (indexPath.section == 1) }
        let task = filteredTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            if let index = self?.viewModel.tasks.firstIndex(where: { $0.title == task.title }) {
                self?.viewModel.deleteTask(at: index)
            }
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
