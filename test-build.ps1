# 测试构建脚本 - 确保本地构建正常

Write-Host "🔧 测试本地构建..." -ForegroundColor Green
Write-Host ""

# 检查必要工具
Write-Host "📋 检查环境..." -ForegroundColor Blue

$errors = @()

# 检查Node.js
try {
    $nodeVersion = node --version
    Write-Host "   ✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    $errors += "❌ Node.js 未安装"
}

# 检查npm
try {
    $npmVersion = npm --version
    Write-Host "   ✅ npm: v$npmVersion" -ForegroundColor Green
} catch {
    $errors += "❌ npm 未安装"
}

# 检查Rust
try {
    $rustVersion = rustc --version
    Write-Host "   ✅ Rust: $rustVersion" -ForegroundColor Green
} catch {
    $errors += "❌ Rust 未安装"
}

# 检查Cargo
try {
    $cargoVersion = cargo --version
    Write-Host "   ✅ Cargo: $cargoVersion" -ForegroundColor Green
} catch {
    $errors += "❌ Cargo 未安装"
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ 环境检查失败：" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    exit 1
}

Write-Host ""
Write-Host "🎨 构建前端..." -ForegroundColor Blue
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 前端构建失败" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ 前端构建成功" -ForegroundColor Green

Write-Host ""
Write-Host "🦀 构建Rust后端..." -ForegroundColor Blue
Set-Location src-tauri
cargo build --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Rust构建失败" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "   ✅ Rust构建成功" -ForegroundColor Green
Set-Location ..

Write-Host ""
Write-Host "📦 生成安装包..." -ForegroundColor Blue
npm run tauri build

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ 完整构建成功！" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📁 生成的文件：" -ForegroundColor Cyan
    
    # 检查可执行文件
    if (Test-Path "src-tauri\target\release\ATM.exe") {
        $size = [math]::Round((Get-Item "src-tauri\target\release\ATM.exe").Length / 1MB, 2)
        Write-Host "   📄 ATM.exe (${size}MB)" -ForegroundColor Gray
    }
    
    # 检查安装包
    $bundlePath = "src-tauri\target\release\bundle"
    if (Test-Path $bundlePath) {
        Get-ChildItem $bundlePath -Recurse -File | ForEach-Object {
            $size = [math]::Round($_.Length / 1MB, 2)
            $relativePath = $_.FullName.Replace((Get-Location).Path, ".")
            Write-Host "   📦 $($_.Name) (${size}MB)" -ForegroundColor Gray
        }
    }
    
} else {
    Write-Host "   ❌ 安装包生成失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 可能的解决方案：" -ForegroundColor Yellow
    Write-Host "   1. 检查NSIS是否正确安装" -ForegroundColor White
    Write-Host "   2. 尝试只构建可执行文件（已成功）" -ForegroundColor White
    Write-Host "   3. 使用GitHub Actions构建完整版本" -ForegroundColor White
}

Write-Host ""
Write-Host "✨ 测试完成！" -ForegroundColor Green
