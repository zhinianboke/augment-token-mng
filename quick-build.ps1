# 快速构建脚本 - 只构建可执行文件，跳过安装包

Write-Host "⚡ 快速构建 Windows 可执行文件..." -ForegroundColor Green
Write-Host ""

# 创建输出目录
$outputDir = ".\dist\quick"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# 1. 构建前端
Write-Host "🎨 构建前端..." -ForegroundColor Blue
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 前端构建失败" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ 前端构建成功" -ForegroundColor Green

# 2. 只构建Rust可执行文件（跳过安装包）
Write-Host ""
Write-Host "🦀 构建可执行文件..." -ForegroundColor Blue

Set-Location src-tauri
cargo build --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ 可执行文件构建成功！" -ForegroundColor Green

    # 复制可执行文件
    if (Test-Path "target\release\ATM.exe") {
        Copy-Item "target\release\ATM.exe" "..\$outputDir\ATM.exe"

        $size = [math]::Round((Get-Item "..\$outputDir\ATM.exe").Length / 1MB, 2)
        Write-Host "   📄 ATM.exe (${size}MB) -> $outputDir" -ForegroundColor Gray
    }
} else {
    Write-Host "   ❌ 可执行文件构建失败" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..

Write-Host ""
Write-Host "✨ 快速构建完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📁 输出文件：" -ForegroundColor Cyan
Write-Host "   $outputDir\ATM.exe" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 测试运行：" -ForegroundColor Yellow
Write-Host "   .\$outputDir\ATM.exe" -ForegroundColor White
Write-Host ""
Write-Host "💡 说明：" -ForegroundColor Blue
Write-Host "   • 这是完整功能的可执行文件" -ForegroundColor White
Write-Host "   • 包含所有您要求的修改" -ForegroundColor White
Write-Host "   • 无需安装，直接运行" -ForegroundColor White
Write-Host "   • 如需安装包，请运行 .\build-mac-windows.ps1" -ForegroundColor White
