# Mac + Windows 构建脚本

param(
    [switch]$Help
)

if ($Help) {
    Write-Host "🍎🪟 ATM Mac + Windows 构建脚本" -ForegroundColor Green
    Write-Host ""
    Write-Host "功能："
    Write-Host "  ✅ 构建Windows版本（本地）"
    Write-Host "  📋 准备GitHub Actions自动构建Mac版本"
    Write-Host ""
    Write-Host "用法："
    Write-Host "  .\build-mac-windows.ps1        # 执行构建"
    Write-Host "  .\build-mac-windows.ps1 -Help  # 显示帮助"
    Write-Host ""
    Write-Host "输出："
    Write-Host "  📁 .\dist\windows\  - Windows安装包和可执行文件"
    Write-Host "  📁 GitHub Actions   - Mac版本（需要推送代码）"
    exit 0
}

Write-Host "🍎🪟 ATM Mac + Windows 构建开始..." -ForegroundColor Green
Write-Host "⏰ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# 创建输出目录
$outputDir = ".\dist\windows"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# 1. 构建Windows版本
Write-Host "🪟 构建Windows版本..." -ForegroundColor Blue

# 确保配置正确（Windows + Mac targets）
$configPath = "src-tauri\tauri.conf.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
$config.bundle.targets = @("nsis", "msi")
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

Write-Host "   📦 开始编译..." -ForegroundColor Gray
npm run tauri build

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Windows版本构建成功！" -ForegroundColor Green
    
    # 复制文件到输出目录
    Write-Host "   📁 整理输出文件..." -ForegroundColor Gray
    
    # 复制可执行文件
    if (Test-Path "src-tauri\target\release\ATM.exe") {
        Copy-Item "src-tauri\target\release\ATM.exe" "$outputDir\ATM.exe"
        Write-Host "      ✓ ATM.exe" -ForegroundColor Green
    }
    
    # 复制NSIS安装包
    $nsisPath = "src-tauri\target\release\bundle\nsis"
    if (Test-Path $nsisPath) {
        Get-ChildItem "$nsisPath\*.exe" | ForEach-Object {
            Copy-Item $_.FullName "$outputDir\$($_.Name)"
            Write-Host "      ✓ $($_.Name)" -ForegroundColor Green
        }
    }
    
    # 复制MSI安装包
    $msiPath = "src-tauri\target\release\bundle\msi"
    if (Test-Path $msiPath) {
        Get-ChildItem "$msiPath\*.msi" | ForEach-Object {
            Copy-Item $_.FullName "$outputDir\$($_.Name)"
            Write-Host "      ✓ $($_.Name)" -ForegroundColor Green
        }
    }
    
} else {
    Write-Host "   ❌ Windows版本构建失败" -ForegroundColor Red
    Write-Host "   💡 请检查错误信息并重试" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📊 构建结果：" -ForegroundColor Green

# 显示Windows构建结果
if (Test-Path $outputDir) {
    Write-Host "🪟 Windows版本：" -ForegroundColor Blue
    Get-ChildItem $outputDir | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "   📄 $($_.Name) (${size}MB)" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ 未找到Windows构建文件" -ForegroundColor Red
}

Write-Host ""
Write-Host "🍎 Mac版本构建说明：" -ForegroundColor Blue
Write-Host "   Mac版本需要在macOS系统上构建，推荐使用GitHub Actions：" -ForegroundColor White
Write-Host ""
Write-Host "   1️⃣ 推送代码到GitHub：" -ForegroundColor Yellow
Write-Host "      git add ." -ForegroundColor Gray
Write-Host "      git commit -m 'Update build for Mac + Windows'" -ForegroundColor Gray
Write-Host "      git push" -ForegroundColor Gray
Write-Host ""
Write-Host "   2️⃣ GitHub Actions会自动构建Mac版本" -ForegroundColor Yellow
Write-Host "   3️⃣ 在GitHub的Actions页面下载Mac安装包" -ForegroundColor Yellow
Write-Host ""
Write-Host "   🔗 GitHub Actions地址：" -ForegroundColor Cyan
Write-Host "      https://github.com/your-username/your-repo/actions" -ForegroundColor Gray

Write-Host ""
Write-Host "🎯 下一步：" -ForegroundColor Green
Write-Host "   • 测试Windows版本：$outputDir\ATM.exe" -ForegroundColor White
Write-Host "   • 推送代码获取Mac版本" -ForegroundColor White
Write-Host "   • 所有功能修改已包含：" -ForegroundColor White
Write-Host "     - ❌ 数据库配置菜单已隐藏" -ForegroundColor Gray
Write-Host "     - ❌ 存储状态组件已隐藏" -ForegroundColor Gray
Write-Host "     - ✅ 核心Token管理功能保留" -ForegroundColor Gray

Write-Host ""
Write-Host "✨ 构建完成！" -ForegroundColor Green
