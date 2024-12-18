import UIKit
import SnapKit

class TaskTableViewCell: UITableViewCell {
    private let checkBox = UIButton()
    private let taskLabel = UILabel()
    private let categoryLabel = UILabel()
    var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        checkBox.setImage(UIImage(systemName: "circle"), for: .normal)
        checkBox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkBox.tintColor = .systemBlue
        checkBox.addTarget(self, action: #selector(toggleCheck), for: .touchUpInside)
        contentView.addSubview(checkBox)
        
        checkBox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        taskLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(taskLabel)
        
        taskLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBox.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        categoryLabel.font = .systemFont(ofSize: 12)
        categoryLabel.textColor = .white
        categoryLabel.textAlignment = .center
        categoryLabel.layer.cornerRadius = 8
        categoryLabel.layer.masksToBounds = true
        contentView.addSubview(categoryLabel)
        
        categoryLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(24)
        }
    }

    func configure(with task: String, category: String, isDone: Bool) {
        taskLabel.attributedText = nil
        taskLabel.text = task

        if isDone {
            checkBox.isSelected = true
            taskLabel.textColor = .systemGray
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.systemGray
            ]
            taskLabel.attributedText = NSAttributedString(string: task, attributes: attributes)
        } else {
            checkBox.isSelected = false
            taskLabel.textColor = .black
            taskLabel.attributedText = NSAttributedString(string: task)
        }

        categoryLabel.text = category
        categoryLabel.backgroundColor = category == "Fitness" ? .systemOrange : .systemBlue
    }



    @objc private func toggleCheck() {
        checkBox.isSelected.toggle()
        onToggle?()
    }
}
