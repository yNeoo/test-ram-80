# test-ram-80
Test rendimiento RAM local, 80% max con auto-liberacion.

Uso:
powershell -ExecutionPolicy Bypass -File stress_ram_80.ps1 -Percent 80 -Seconds 30

Espera proceso:
powershell -ExecutionPolicy Bypass -File stress_ram_80.ps1 -Percent 80 -ProcessName notepad -MaxSeconds 600

