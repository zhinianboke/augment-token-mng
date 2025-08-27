# PowerShell脚本：在Windows上使用Docker构建Linux版本

Write-Host "🐧 开始构建Linux版本..." -ForegroundColor Green

# 检查Docker是否安装
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ 错误：未找到Docker。请先安装Docker Desktop。" -ForegroundColor Red
    Write-Host "下载地址：https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# 检查Docker是否运行
try {
    docker version | Out-Null
} catch {
    Write-Host "❌ 错误：Docker未运行。请启动Docker Desktop。" -ForegroundColor Red
    exit 1
}

# 创建输出目录
$outputDir = ".\dist\linux"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "🔨 构建Docker镜像..." -ForegroundColor Blue
docker build -f Dockerfile.linux -t atm-linux-builder .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker镜像构建失败" -ForegroundColor Red
    exit 1
}

Write-Host "📦 运行构建容器..." -ForegroundColor Blue
docker run --rm -v "${PWD}\${outputDir}:/output" atm-linux-builder

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Linux版本构建完成！" -ForegroundColor Green
    Write-Host "📁 输出目录：$outputDir" -ForegroundColor Yellow
    
    # 显示生成的文件
    if (Test-Path $outputDir) {
        Write-Host "📋 生成的文件：" -ForegroundColor Cyan
        Get-ChildItem $outputDir -Recurse | Where-Object { !$_.PSIsContainer } | ForEach-Object {
            Write-Host "   $($_.FullName)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "❌ Linux版本构建失败" -ForegroundColor Red
    exit 1
}
