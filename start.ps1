Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Запуск конвейера автоматизации GoldJargSource" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$legionPath = ".\app\legion"
if (Test-Path $legionPath) {
    Get-ChildItem -Path $legionPath -Filter "*.h" -Recurse | Remove-Item -Force
    Write-Host "[Успех] Все .h файлы удалены из app/legion. Больше никакой мишуры!" -ForegroundColor Green
} else {
    Write-Host "[Ошибка] Путь $legionPath не найден!" -ForegroundColor Red
}

$mcpUri = "http://localhost:8080/mcp/translate"
Write-Host "[MCP] Проверка связи с mcp_dart_copilot..." -ForegroundColor Yellow

try {
    # Отправляем тестовый пинг на ваш сервер Dart
    $testDoc = @{ ping = "test" } | ConvertTo-Json
    $ping = Invoke-RestMethod -Uri $mcpUri -Method Post -Body $testDoc -ContentType "application/json" -TimeoutSec 3
    Write-Host "[MCP] Сервер на Dart успешно обнаружен и готов к прошивке!" -ForegroundColor Green
} catch {
    Write-Host "[Предупреждение] Ошибка связи с MCP сервером. Убедитесь, что 'server.dart' запущен." -ForegroundColor Yellow
}
