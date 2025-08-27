# PowerShell脚本：尝试交叉编译（仅限可执行文件，不包括安装包）

Write-Host "🔧 开始交叉编译..." -ForegroundColor Green

# 检查Rust是否安装
if (!(Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 错误：未找到Rust。请先安装Rust。" -ForegroundColor Red
    Write-Host "安装地址：https://rustup.rs/" -ForegroundColor Yellow
    exit 1
}

# 安装交叉编译目标
Write-Host "📥 安装交叉编译目标..." -ForegroundColor Blue

$targets = @(
    "x86_64-unknown-linux-gnu",
    "aarch64-unknown-linux-gnu"
)

foreach ($target in $targets) {
    Write-Host "   添加目标：$target" -ForegroundColor Gray
    rustup target add $target
}

# 创建输出目录
$outputDir = ".\dist\cross-compile"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# 构建前端
Write-Host "🎨 构建前端..." -ForegroundColor Blue
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 前端构建失败" -ForegroundColor Red
    exit 1
}

# 交叉编译各个目标
foreach ($target in $targets) {
    Write-Host "🔨 编译目标：$target" -ForegroundColor Blue
    
    Set-Location src-tauri
    cargo build --release --target $target
    
    if ($LASTEXITCODE -eq 0) {
        $exeName = if ($target.Contains("windows")) { "ATM.exe" } else { "ATM" }
        $sourcePath = "target\$target\release\$exeName"
        $destPath = "..\$outputDir\ATM-$target$( if ($target.Contains('windows')) { '.exe' } )"
        
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath $destPath
            Write-Host "   ✅ 成功：$destPath" -ForegroundColor Green
        } else {
            Write-Host "   ❌ 失败：未找到 $sourcePath" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ 编译失败：$target" -ForegroundColor Red
    }
    
    Set-Location ..
}

Write-Host "📋 交叉编译完成！" -ForegroundColor Green
Write-Host "📁 输出目录：$outputDir" -ForegroundColor Yellow

# 显示生成的文件
if (Test-Path $outputDir) {
    Write-Host "📋 生成的文件：" -ForegroundColor Cyan
    Get-ChildItem $outputDir | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "   $($_.Name) (${size}MB)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "⚠️  注意：交叉编译只能生成可执行文件，无法生成安装包。" -ForegroundColor Yellow
Write-Host "   如需完整的安装包，请使用Docker方案或GitHub Actions。" -ForegroundColor Yellow
