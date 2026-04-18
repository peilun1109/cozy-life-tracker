param(
  [string]$Root = "build\web",
  [int]$Port = 8080
)

$resolvedRoot = Resolve-Path -LiteralPath $Root
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Serving $resolvedRoot at http://127.0.0.1:$Port/"
Write-Host "Press Ctrl+C to stop."

$contentTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".js" = "application/javascript; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".png" = "image/png"
  ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif" = "image/gif"
  ".svg" = "image/svg+xml"
  ".ico" = "image/x-icon"
  ".wasm" = "application/wasm"
  ".ttf" = "font/ttf"
  ".otf" = "font/otf"
  ".txt" = "text/plain; charset=utf-8"
}

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $requestPath = [System.Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))

    if ([string]::IsNullOrWhiteSpace($requestPath)) {
      $requestPath = "index.html"
    }

    $localPath = Join-Path $resolvedRoot $requestPath

    if ((Test-Path -LiteralPath $localPath) -and -not (Get-Item -LiteralPath $localPath).PSIsContainer) {
      $file = Get-Item -LiteralPath $localPath
    } else {
      $file = Get-Item -LiteralPath (Join-Path $resolvedRoot "index.html")
    }

    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $extension = $file.Extension.ToLowerInvariant()
    $context.Response.ContentType = $contentTypes[$extension]
    if (-not $context.Response.ContentType) {
      $context.Response.ContentType = "application/octet-stream"
    }
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.OutputStream.Close()
  }
}
finally {
  $listener.Stop()
  $listener.Close()
}
