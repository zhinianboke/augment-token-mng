# 🚀 ATM 构建指南

## 📦 支持的平台

- ✅ **Windows** (本地构建)
- ✅ **macOS** (GitHub Actions)

## 🔧 本地构建 (Windows)

### 前置要求

1. **Node.js** (LTS版本)
2. **Rust** (最新稳定版)
3. **Visual Studio Build Tools** (Windows)

### 快速构建

```powershell
# 测试环境和构建
.\test-build.ps1

# 构建Windows版本
.\build-mac-windows.ps1
```

### 手动构建

```powershell
# 1. 安装依赖
npm install

# 2. 构建前端
npm run build

# 3. 构建应用
npm run tauri build
```

## 🍎 macOS 构建 (GitHub Actions)

### 自动构建

1. **推送代码到GitHub：**
   ```bash
   git add .
   git commit -m "Update for Mac build"
   git push
   ```

2. **查看构建状态：**
   - 访问 GitHub 仓库的 Actions 页面
   - 等待构建完成（约5-10分钟）

3. **下载构建产物：**
   - 点击完成的构建任务
   - 下载 `macOS` 构建产物

### 手动触发构建

在GitHub仓库页面：
1. 点击 "Actions" 标签
2. 选择 "Build Mac and Windows" 工作流
3. 点击 "Run workflow"

## 📁 输出文件

### Windows 版本
```
dist/windows/
├── ATM.exe                    # 可执行文件
├── ATM_0.3.0_x64-setup.exe    # NSIS安装包
└── ATM_0.3.0_x64_en-US.msi    # MSI安装包
```

### macOS 版本 (GitHub Actions)
```
macOS/
├── ATM_0.3.0_x64.dmg          # 磁盘映像
└── ATM.app/                   # 应用包
```

## 🐛 故障排除

### Windows 构建问题

1. **NSIS 下载失败**
   ```powershell
   # 解决方案：使用已有的可执行文件
   # 文件位置：src-tauri/target/release/ATM.exe
   ```

2. **Rust 编译错误**
   ```powershell
   # 更新 Rust
   rustup update
   
   # 清理缓存
   cargo clean
   ```

3. **Node.js 依赖问题**
   ```powershell
   # 清理并重新安装
   rm -rf node_modules package-lock.json
   npm install
   ```

### GitHub Actions 问题

1. **构建失败**
   - 检查 Actions 页面的错误日志
   - 确保所有文件已正确推送

2. **权限问题**
   - 确保仓库设置中启用了 Actions
   - 检查 GITHUB_TOKEN 权限

## ✨ 功能特性

本版本包含以下修改：
- ❌ 隐藏数据库配置菜单
- ❌ 隐藏存储状态组件
- ✅ 保留核心Token管理功能
- ✅ 修复网络连接问题
- ✅ Portal URL自动设置

## 📞 支持

如果遇到构建问题：
1. 运行 `.\test-build.ps1` 检查环境
2. 查看错误日志
3. 检查本文档的故障排除部分
