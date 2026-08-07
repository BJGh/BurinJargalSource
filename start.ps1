Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " Запуск гигаумного MCP-транслятора GoldJargSource " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Пути к исходникам и будущему C# коду
$srcPath = ".\app\legion"
$targetPath = ".\sourcesharp\app\legion"

# Создаем целевую папку, если её нет
if (!(Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath | Out-Null }

# Локальный эндпоинт вашего прокачанного MCP Dart сервера
$mcpUri = "http://localhost:8080/mcp/translate"

# Находим ВСЕ .cpp файлы в папке и запускаем массовый поток
Get-ChildItem -Path $srcPath -Filter "*.cpp" -Recurse | ForEach-Object {
    $currentFile = $_.Name
    $newFileName = $_.Name -replace '\.cpp$', '.cs'
    $targetFileFullPath = Join-Path $targetPath $newFileName

    Write-Host "[Конвейер] Обработка: $currentFile -> $newFileName..." -ForegroundColor Yellow

    # Читаем сырой C++ код "в лоб"
    $cppCode = Get-Content $_.FullName -Raw

    # Формируем JSON-пакет для вашего MCP-сервера
    $payload = @{
        filename = $currentFile
        rules = "sichem-hebron-net10"
        code = $cppCode
    } | ConvertTo-Json

    try {
        # Отправляем на прошивку в backbonebrains через Dart MCP
        $response = Invoke-RestMethod -Uri $mcpUri -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 10
        
        # Сохраняем результат один-в-один с расширением .cs
        Set-Content -Path $targetFileFullPath -Value $response.translatedCode
        Write-Host "[Успех] Файл $newFileName успешно сгенерирован!" -ForegroundColor Green
    }
    catch {
        Write-Host "[Ошибка] Не удалось транслировать файл $currentFile. Ошибка сервера." -ForegroundColor Red
    }
}

# Удаляем старые .h файлы, чтобы очистить директорию перед компиляцией
Get-ChildItem -Path $srcPath -Filter "*.h" -Recurse | Remove-Item -Force
Write-Host "[Зачистка] Все заголовочные файлы удалены. Кодовая база чиста!" -ForegroundColor Cyan
