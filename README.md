# SwiftMermind

一个用于在 SwiftUI 应用中渲染 Mermaid 图表的 Swift 包。该库提供了 Mermaid.js 功能的 SwiftUI 原生实现，允许您直接在 iOS 和 macOS 应用中创建精美的图表。

## 特性

- ✅ **流程图 (Flowchart diagrams)** - 完全实现，支持节点形状和边连接
- ✅ **时序图 (Sequence diagrams)** - 基本实现，支持参与者和消息
- ✅ **饼图 (Pie charts)** - 数据可视化，支持自定义颜色
- 🚧 **类图 (Class diagrams)** - 即将推出
- 🚧 **状态图 (State diagrams)** - 即将推出
- 🚧 **甘特图 (Gantt charts)** - 即将推出
- 🚧 **Git 图 (Git graphs)** - 即将推出
- 🚧 **ER 图 (ER diagrams)** - 即将推出
- 🚧 **用户旅程图 (User journey maps)** - 即将推出

## 系统要求

- iOS 16.0+ / macOS 13.0+
- Swift 6.0+
- Xcode 15.0+

## 安装

### Swift Package Manager

使用 Swift Package Manager 将 SwiftMermind 添加到您的项目中：

1.  在 Xcode 中，前往 File → Add Package Dependencies
2.  输入仓库 URL: `https://github.com/yourusername/SwiftMermind`
3.  选择您要使用的版本
4.  将包添加到您的目标 (target)

或者，将其添加到您的 `Package.swift` 文件中：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftMermind", from: "1.0.0")
]
```

## 用法

### 基本用法

导入 SwiftMermind 并使用 `mermindView` 组件：

```swift
import SwiftUI
import SwiftMermind

struct ContentView: View {
    var body: some View {
        mermindView(text: """
            graph TD
                A[Start] --> B{Is it working?}
                B -->|Yes| C[Great!]
                B -->|No| D[Debug]
                D --> B
                C --> E[End]
        """)
        .frame(width: 400, height: 300)
    }
}
```

### 流程图示例

```swift
mermindView(text: """
    graph TD
        A[Start] --> B{Decision Point}
        B -->|Option 1| C[Process A]
        B -->|Option 2| D[Process B]
        C --> E[End]
        D --> E
""")
```

### 时序图示例

```swift
mermindView(text: """
    sequenceDiagram
        participant Alice
        participant Bob
        participant Charlie

        Alice->>Bob: Hello Bob!
        Bob-->>Alice: Hi Alice!
        Alice->>Charlie: How are you?
        Charlie-->>Alice: I'm good, thanks!
""")
```

### 饼图示例

```swift
mermindView(text: """
    pie title Survey Results
        "Satisfied" : 45
        "Neutral" : 30
        "Dissatisfied" : 25
""")
```

### 使用预定义示例

SwiftMermind 自带了几个预定义示例：

```swift
// 流程图示例
mermindView.flowchartExample()

// 时序图示例
mermindView.sequenceExample()

// 饼图示例
mermindView.pieExample()

// 类图示例 (占位符)
mermindView.classExample()
```

## 支持的 Mermaid 语法

### 流程图

- **节点形状**: 矩形 `[text]`、圆角矩形 `(text)`、圆形 `((text))`、菱形 `{text}`、六边形 `{{text}}`
- **连接**: 箭头 `-->`、直线 `---`、虚线箭头 `-.->`、粗箭头 `==>`
- **标签**: `A -->|label| B`
- **方向**: `TD` (从上到下 Top Down)、`LR` (从左到右 Left Right)、`BT` (从下到上 Bottom Top)、`RL` (从右到左 Right Left)

### 时序图

- **参与者**: `participant Alice`、`actor Bob`
- **消息**: `Alice->>Bob: Message`、`Alice-->>Bob: Dotted message` (虚线消息)
- **激活**: 即将推出
- **注释**: 即将推出

### 饼图

- **基本语法**: `pie title "Title"`
- **数据条目**: `"Label" : value`

## 自定义

### 节点样式

您可以通过修改 `NodeStyle` 属性来自定义节点外观：

```swift
let customStyle = NodeStyle(
    fillColor: .blue,
    strokeColor: .black,
    strokeWidth: 2.0,
    textColor: .white,
    fontSize: 16.0,
    fontWeight: .bold
)
```

### 边样式

使用 `EdgeStyle` 自定义边外观：

```swift
let customEdgeStyle = EdgeStyle(
    strokeColor: .red,
    strokeWidth: 2.0,
    textColor: .black,
    fontSize: 14.0
)
```

## 架构

SwiftMermind 包含以下几个关键组件：

- **`mermindView`**: 主要的 SwiftUI 视图组件
- **`MermaidParser`**: 将 Mermaid 语法解析为结构化数据
- **`FlowchartView`**: 渲染流程图
- **`SequenceDiagramView`**: 渲染时序图
- **`PieChartView`**: 渲染饼图
- **特定图表视图**: 用于其他图表类型 (即将推出)

## 贡献

欢迎贡献！请随时提交 Pull Request。特别需要帮助的领域包括：

- 实现额外的图表类型
- 改进解析算法
- 添加更多自定义选项
- 性能优化
- Bug 修复和测试

## 许可证

SwiftMermind 在 MIT 许可证下可用。更多信息请参见 LICENSE 文件。

## 路线图

- [ ] 完成所有主要 Mermaid 图表类型的实现
- [ ] 高级样式和主题支持
- [ ] 动画支持
- [ ] 导出为图片功能
- [ ] 交互式图表
- [ ] 大型图表的性能优化
- [ ] 可访问性改进

## 致谢

- 灵感来源于 [Mermaid.js](https://mermaid-js.github.io/mermaid/)
- 使用 SwiftUI 和 Swift 6 构建

---

更多示例和详细文档，请访问我们的 [GitHub 仓库](https://github.com/yourusername/SwiftMermind)。