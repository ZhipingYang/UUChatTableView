# UUChatTableView

一个轻量的 Objective-C 聊天气泡组件，保留了最核心的消息模型、布局计算、Cell 渲染和输入栏逻辑，并提供了一个纯代码 Demo。

## 当前结构

- `Class/`
  组件源码，包含消息模型、布局、Cell、输入栏、语音播放和图片预览。
- `Demo/`
  纯代码 Demo，工程由 `project.yml` 生成，再通过 CocoaPods 接入当前仓库的 `podspec`。
- `UUChatTableView.podspec`
  发布配置，可直接用于 `pod lib lint` / 发布流程。

## Demo 运行方式

```bash
cd Demo
xcodegen generate
pod install
open UUChatTableViewDemo.xcworkspace
```

Demo 内置假数据，默认覆盖：

- 文本消息
- 图片消息
- 语音消息
- 私聊 / 群聊切换
- 下拉加载历史消息

## Pod 集成

```ruby
pod 'UUChatTableView'
```

本地联调可以直接使用：

```ruby
pod 'UUChatTableView', :path => '..'
```

## 核心类

- `UUMessage`
  消息模型，统一文字、图片、语音和时间信息。
- `UUMessageFrame`
  负责消息布局计算和 Cell 高度。
- `UUMessageCell`
  负责聊天气泡渲染、头像点击、图片预览、语音播放。
- `UUInputFunctionView`
  纯代码输入栏，支持文本、图片和按住录音。

## 验证

当前仓库已经通过以下本地验证：

- `xcodegen generate`
- `pod install`
- `xcodebuild -workspace Demo/UUChatTableViewDemo.xcworkspace -scheme UUChatTableViewDemo -sdk iphonesimulator -configuration Debug build CODE_SIGNING_ALLOWED=NO`
- `pod lib lint UUChatTableView.podspec --allow-warnings --skip-tests`
