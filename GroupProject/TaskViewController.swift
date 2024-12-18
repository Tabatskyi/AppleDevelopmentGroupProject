import UIKit
import SnapKit

class TaskViewController: UIViewController {
    private var tasks: [(name: String, category: String, isDone: Bool)] = []
    private let tableView = UITableView()
    private let inputField = UITextField()
    private let addButton = UIButton(type: .system)
    private let separatorView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
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
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
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
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = 60
    }

    @objc private func addTask() {
        guard let taskName = inputField.text, !taskName.isEmpty else { return }
        tasks.append((name: taskName, category: "To-Do", isDone: false))
        inputField.text = ""
        tableView.reloadData()
    }
}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let toDoCount = tasks.filter { !$0.isDone }.count
        let doneCount = tasks.filter { $0.isDone }.count
        
        if section == 0 {
            return "To-Do (\(toDoCount))"
        } else {
            return "Done (\(doneCount))"
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.filter { $0.isDone == (section == 1) }.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        
        let filteredTasks = tasks.filter { $0.isDone == (indexPath.section == 1) }
        let task = filteredTasks[indexPath.row]
        
        cell.configure(with: task.name, category: task.category, isDone: task.isDone)
        
        cell.onToggle = { [weak self] in
            guard let self = self else { return }
            if let index = self.tasks.firstIndex(where: { $0.name == task.name }) {
                self.tasks[index].isDone.toggle()
                self.tableView.reloadData()
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let filteredIndices = tasks.indices.filter { tasks[$0].isDone == (indexPath.section == 1) }
            tasks.remove(at: filteredIndices[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }

}
