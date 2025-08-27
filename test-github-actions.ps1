# 测试GitHub Actions本地模拟

Write-Host "🧪 模拟GitHub Actions构建流程..." -ForegroundColor Green
Write-Host ""

# 1. 清理环境
Write-Host "🧹 清理环境..." -ForegroundColor Blue
if (Test-Path "node_modules") {
    Write-Host "   删除 node_modules..." -ForegroundColor Gray
    Remove-Item "node_modules" -Recurse -Force
}

if (Test-Path "dist") {
    Write-Host "   删除 dist..." -ForegroundColor Gray
    Remove-Item "dist" -Recurse -Force
}

# 2. 安装依赖（模拟GitHub Actions）
Write-Host ""
Write-Host "📦 安装依赖 (npm ci)..." -ForegroundColor Blue
npm ci

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依赖安装失败" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ 依赖安装成功" -ForegroundColor Green

# 3. 构建前端
Write-Host ""
Write-Host "🎨 构建前端..." -ForegroundColor Blue
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 前端构建失败" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ 前端构建成功" -ForegroundColor Green

# 4. 检查前端输出
if (Test-Path "dist") {
    Write-Host "   📁 前端输出文件：" -ForegroundColor Gray
    Get-ChildItem "dist" -Recurse | ForEach-Object {
        if (!$_.PSIsContainer) {
            Write-Host "      $($_.Name)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "❌ 前端输出目录不存在" -ForegroundColor Red
    exit 1
}

# 5. 检查Tauri配置
Write-Host ""
Write-Host "⚙️  检查Tauri配置..." -ForegroundColor Blue

$configPath = "src-tauri\tauri.conf.json"
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        Write-Host "   ✅ 配置文件格式正确" -ForegroundColor Green
        Write-Host "   📋 应用名称: $($config.productName)" -ForegroundColor Gray
        Write-Host "   📋 版本: $($config.version)" -ForegroundColor Gray
        Write-Host "   📋 打包目标: $($config.bundle.targets -join ', ')" -ForegroundColor Gray
    } catch {
        Write-Host "❌ 配置文件格式错误: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ 配置文件不存在" -ForegroundColor Red
    exit 1
}

# 6. 测试Rust编译
Write-Host ""
Write-Host "🦀 测试Rust编译..." -ForegroundColor Blue

Set-Location src-tauri
cargo check

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Rust代码检查通过" -ForegroundColor Green
} else {
    Write-Host "❌ Rust代码检查失败" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

Write-Host ""
Write-Host "🎯 GitHub Actions模拟测试结果：" -ForegroundColor Green
Write-Host "   ✅ 依赖安装 - 正常" -ForegroundColor White
Write-Host "   ✅ 前端构建 - 正常" -ForegroundColor White
Write-Host "   ✅ 配置文件 - 正常" -ForegroundColor White
Write-Host "   ✅ Rust代码 - 正常" -ForegroundColor White

Write-Host ""
Write-Host "💡 建议：" -ForegroundColor Yellow
Write-Host "   1. 推送代码到GitHub触发Actions" -ForegroundColor White
Write-Host "   2. 如果仍然失败，检查GitHub Actions日志" -ForegroundColor White
Write-Host "   3. 确保仓库设置中启用了Actions" -ForegroundColor White

Write-Host ""
Write-Host "✨ 本地测试完成！" -ForegroundColor Green
