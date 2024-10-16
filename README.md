# TaskFlow

TaskFlow 是一个简洁高效的 ToDo 应用，结合了卡片视图和时间轴视图，旨在帮助用户直观地管理任务和安排时间。无论是日常待办事项还是长期目标，TaskFlow 都能让你轻松掌控。

## 功能特点

- **卡片视图**：以卡片形式展示任务，便于快速浏览和编辑。
- **时间轴视图**：按时间顺序排列任务，直观展示任务的时间进度。
- **截止日期提醒**：通过时间轴视图自动提醒即将到期的任务。
  
## 技术栈

- **Flutter**：使用 Dart 语言开发的跨平台 UI 框架，支持 Android 和 iOS。
- **SQLite**：轻量级、快速的本地数据库，用于存储任务数据。

## 安装与运行

### 1. 克隆项目

首先，克隆此仓库到你的本地开发环境：

```bash
git clone https://github.com/NihilDigit/task_flow.git
cd taskflow
```

### 2. 安装依赖

确保你已经安装了 Flutter 环境。然后运行以下命令以安装项目依赖：

```bash
flutter pub get
```

### 3. 运行项目

在连接的设备（模拟器或真实设备）上运行项目：

```bash
flutter run
```

### 4. 构建 APK 或 IPA

要构建 Android APK 或 iOS IPA，请运行以下命令：

- Android APK:
  
  ```bash
  flutter build apk --release
  ```

- iOS IPA:

  ```bash
  flutter build ios --release
  ```

## 目录结构

```plaintext
taskflow/
│
├── lib/
│   ├── helpers/              # 数据库帮助类
│   │   └── database_helper.dart
│   ├── models/               # 数据模型
│   │   └── todo_item.dart
│   ├── screens/              # 应用的不同页面
│   │   ├── card_view.dart      # 卡片视图页面
│   │   ├── home_screen.dart    # 首页
│   │   └── timeline_view.dart  # 时间轴视图页面
│   ├── widgets/              # 自定义 widget 组件
│   │   ├── todo_item_card_widget.dart    # 卡片任务显示组件
│   │   └── todo_item_timeline_widget.dart  # 时间轴任务显示组件
│   └── main.dart             # 应用主入口
│
├── assets/
│   ├── images/               # 应用图片资源
│   └── fonts/                # 字体资源
│
├── test/                     # 测试文件
├── pubspec.yaml              # 项目的配置文件
└── README.md                 # 项目说明文件
```

## 贡献指南

欢迎贡献代码！如果你有任何想法或发现了 bug，欢迎提交 [Issue](https://github.com/NihilDigit/task_flow/issues) 或发送 PR。

### 贡献流程

1. Fork 本仓库
2. 创建你的功能分支 (`git checkout -b feature/new-feature`)
3. 提交你的更改 (`git commit -m 'Add new feature'`)
4. 推送到分支 (`git push origin feature/new-feature`)
5. 创建一个 Pull Request

## 许可证

TaskFlow 使用 [Mozilla Public License 2.0](LICENSE)。

---

感谢你使用 TaskFlow！如果你有任何问题或者建议，请通过 [Issues](https://github.com/NihilDigit/task_flow/issues) 与我们联系。
