# Test rendimiento RAM - solo tu PC, entorno controlado
# Uso 1 (tiempo): powershell -ExecutionPolicy Bypass -File stress_ram_80.ps1 -Percent 80 -Seconds 30
# Uso 2 (hasta que termine proceso): powershell -ExecutionPolicy Bypass -File stress_ram_80.ps1 -Percent 80 -ProcessName notepad -MaxSeconds 600
param(
  [int]$Percent = 80,
  [int]$Seconds = 30,
  [string]$ProcessName = "",
  [int]$MaxSeconds = 600
)
if ($Percent -gt 80) { Write-Error "Max 80 por seguridad"; exit 1 }
$os = Get-CimInstance Win32_OperatingSystem
$freeKB = $os.FreePhysicalMemory
$targetMB = [int]($freeKB / 1024 * ($Percent/100))
Write-Host "RAM libre: $([int]($freeKB/1024)) MB -> voy a reservar aprox $targetMB MB por $Seconds s" -ForegroundColor Yellow
Write-Host "Ctrl+C para abortar. Solo prueba local." -ForegroundColor Cyan
$chunks = @()
try {
  $chunkMB = 50
  $n = [int]($targetMB / $chunkMB)
  for ($i=0; $i -lt $n; $i++) {
    $arr = New-Object byte[] ($chunkMB*1MB)
    # toca memoria para que sea real
    for ($j=0; $j -lt $arr.Length; $j+=4096) { $arr[$j]=1 }
    $chunks += $arr
    if ($i % 10 -eq 0) { Write-Progress -Activity "Reservando RAM" -Status "$i/$n chunks" -PercentComplete ($i/$n*100) }
  }
  Write-Host "Reservado. Manteniendo $Seconds s..." -ForegroundColor Green
  if ($ProcessName -ne "") {
    Write-Host "Esperando a que termine proceso '$ProcessName' (max $MaxSeconds s)..." -ForegroundColor Cyan
    $elapsed = 0
    while ($elapsed -lt $MaxSeconds) {
      $p = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
      if (-not $p) { Write-Host "Proceso terminado, liberando." -ForegroundColor Green; break }
      Start-Sleep -Seconds 2; $elapsed += 2
    }
  } else {
    Start-Sleep -Seconds $Seconds
  }
}
finally {
  $chunks = $null
  [GC]::Collect(); [GC]::WaitForPendingFinalizers()
  Write-Host "Liberado." -ForegroundColor Green
}
