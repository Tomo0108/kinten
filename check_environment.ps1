# Kinten環境確認スクリプト
Write-Host "=== Kinten環境確認 ===" -ForegroundColor Green

# Flutterの確認
Write-Host "`n1. Flutterの確認:" -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter is installed:" -ForegroundColor Green
    Write-Host $flutterVersion
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter: https://docs.flutter.dev/get-started/install" -ForegroundColor Red
}

# Pythonの確認
Write-Host "`n2. Pythonの確認:" -ForegroundColor Yellow
try {
    $pythonVersion = python --version
    Write-Host "✅ Python is installed:" -ForegroundColor Green
    Write-Host $pythonVersion
} catch {
    Write-Host "❌ Python is not installed or not in PATH" -ForegroundColor Red
}

# 仮想環境の確認
Write-Host "`n3. 仮想環境の確認:" -ForegroundColor Yellow
if (Test-Path "venv\Scripts\Activate.ps1") {
    Write-Host "✅ Virtual environment exists" -ForegroundColor Green
} else {
    Write-Host "❌ Virtual environment not found" -ForegroundColor Red
}

# frontend.exeの確認
Write-Host "`n4. frontend.exeの確認:" -ForegroundColor Yellow
$frontendPath = "frontend\build\windows\x64\runner\Release\frontend.exe"
if (Test-Path $frontendPath) {
    Write-Host "✅ frontend.exe found:" -ForegroundColor Green
    Write-Host "Location: $((Get-Item $frontendPath).FullName)" -ForegroundColor Cyan
    Write-Host "Size: $((Get-Item $frontendPath).Length) bytes" -ForegroundColor Cyan
    Write-Host "Last modified: $((Get-Item $frontendPath).LastWriteTime)" -ForegroundColor Cyan
} else {
    Write-Host "❌ frontend.exe not found" -ForegroundColor Red
    Write-Host "Please run: cd frontend && flutter build windows" -ForegroundColor Red
}

# 必要なファイルの確認
Write-Host "`n5. 必要なファイルの確認:" -ForegroundColor Yellow
$requiredFiles = @(
    "input\勤怠詳細_小島　知将_2025_07.csv",
    "templates\勤怠表雛形_2025年版.xlsx",
    "backend\main_processor.py",
    "backend\csv_processor.py",
    "backend\excel_processor.py"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
    }
}

# アプリケーションの実行方法
Write-Host "`n6. アプリケーションの実行方法:" -ForegroundColor Yellow
Write-Host "開発モード:" -ForegroundColor Cyan
Write-Host "  cd frontend && flutter run -d windows" -ForegroundColor White
Write-Host "`nビルド済みアプリ:" -ForegroundColor Cyan
Write-Host "  .\frontend\build\windows\x64\runner\Release\frontend.exe" -ForegroundColor White
Write-Host "  または、エクスプローラーでダブルクリック" -ForegroundColor White

Write-Host "`n=== 確認完了 ===" -ForegroundColor Green 