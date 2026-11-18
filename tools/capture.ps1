# Records the frames Voxel Flight sends over USB (build it with CAPTURE_FRAMES = true).
# Everything the board sends is saved as-is; frames.py picks the frames out of it.
#
#   powershell -ExecutionPolicy Bypass -File tools\capture.ps1 -Port COM4 -Seconds 60 -Out capture.bin
#
# Start it, then press the board's RESET button (or just leave it running) - frames are picked up
# whenever they arrive.
param(
  [string]$Port = "COM4",
  [int]$Seconds = 60,
  [string]$Out = "capture.bin"
)

$sp = New-Object System.IO.Ports.SerialPort $Port, 115200
$sp.ReadBufferSize = 1048576
$sp.DtrEnable = $true
$sp.Open()
$file = [System.IO.File]::Create((Join-Path (Get-Location) $Out))
$buf = New-Object byte[] 65536
$end = (Get-Date).AddSeconds($Seconds)
$total = 0
Write-Host "Recording $Port for $Seconds s into $Out ..."
while ((Get-Date) -lt $end) {
  $n = $sp.BaseStream.Read($buf, 0, $buf.Length)
  if ($n -gt 0) { $file.Write($buf, 0, $n); $total += $n }
}
$file.Close()
$sp.Close()
Write-Host ("Done: {0:N0} bytes (about {1} frames)" -f $total, [int]($total / 8196))
