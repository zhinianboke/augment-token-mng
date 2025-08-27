# 主构建脚本：尝试构建所有平台版本

param(
    [switch]$Docker,
    [switch]$Cross,
    [switch]$WindowsOnly,
    [switch]$Help
)

if ($Help) {
    Write-Host "🔧 ATM 多平台构建脚本" -ForegroundColor Green
    Write-Host ""
    Write-Host "用法："
    Write-Host "  .\build-all.ps1 -WindowsOnly    # 只构建Windows版本（默认）"
    Write-Host "  .\build-all.ps1 -Cross          # 交叉编译Linux可执行文件"
    Write-Host "  .\build-all.ps1 -Docker         # 使用Docker构建Linux完整包"
    Write-Host "  .\build-all.ps1 -Help           # 显示此帮助"
    Write-Host ""
    Write-Host "注意："
    Write-Host "  - Windows版本：完整安装包 + 可执行文件"
    Write-Host "  - 交叉编译：仅Linux可执行文件"
    Write-Host "  - Docker：Linux完整安装包（需要Docker）"
    Write-Host "  - Mac版本：需要在Mac系统上构建或使用GitHub Actions"
    exit 0
}

Write-Host "🚀 ATM 多平台构建开始..." -ForegroundColor Green
Write-Host "⏰ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# 创建总输出目录
$mainOutputDir = ".\dist"
if (!(Test-Path $mainOutputDir)) {
    New-Item -ItemType Directory -Path $mainOutputDir -Force | Out-Null
}

# 1. 构建Windows版本（默认）
if (!$Cross -and !$Docker) {
    $WindowsOnly = $true
}

if ($WindowsOnly -or (!$Cross -and !$Docker)) {
    Write-Host "🪟 构建Windows版本..." -ForegroundColor Blue
    
    # 恢复Windows打包配置
    $configPath = "src-tauri\tauri.conf.json"
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $config.bundle.targets = @("nsis", "msi")
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    
    npm run tauri build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Windows版本构建成功" -ForegroundColor Green
        
        # 复制Windows文件到统一目录
        $winDir = "$mainOutputDir\windows"
        if (!(Test-Path $winDir)) { New-Item -ItemType Directory -Path $winDir -Force | Out-Null }
        
        # 复制可执行文件
        if (Test-Path "src-tauri\target\release\ATM.exe") {
            Copy-Item "src-tauri\target\release\ATM.exe" "$winDir\ATM.exe"
        }
        
        # 复制安装包
        if (Test-Path "src-tauri\target\release\bundle") {
            Copy-Item "src-tauri\target\release\bundle\*" $winDir -Recurse -Force
        }
    } else {
        Write-Host "   ❌ Windows版本构建失败" -ForegroundColor Red
    }
}

# 2. 交叉编译Linux
if ($Cross) {
    Write-Host ""
    Write-Host "🐧 交叉编译Linux版本..." -ForegroundColor Blue
    .\build-cross.ps1
}

# 3. Docker构建Linux
if ($Docker) {
    Write-Host ""
    Write-Host "🐳 Docker构建Linux版本..." -ForegroundColor Blue
    .\build-linux.ps1
}

Write-Host ""
Write-Host "📊 构建总结：" -ForegroundColor Green
Write-Host "📁 输出目录：$mainOutputDir" -ForegroundColor Yellow

if (Test-Path $mainOutputDir) {
    Get-ChildItem $mainOutputDir -Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        $relativePath = $_.FullName.Replace((Get-Location).Path, ".")
        Write-Host "   $relativePath (${size}MB)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🎯 下一步：" -ForegroundColor Cyan
Write-Host "   • 测试Windows版本：.\dist\windows\ATM.exe" -ForegroundColor White
if ($Cross) {
    Write-Host "   • Linux可执行文件：.\dist\cross-compile\" -ForegroundColor White
}
if ($Docker) {
    Write-Host "   • Linux安装包：.\dist\linux\" -ForegroundColor White
}
Write-Host "   • Mac版本：推送到GitHub使用Actions构建" -ForegroundColor White
