$ErrorActionPreference = 'Stop'
$r = 'C:\Users\RDC\Downloads\skibidi-defense-site'
$dst = Join-Path $r 'index.html'
$game = Join-Path $r 'game.html'

#--- 1. Current index.html IS the canonical game; back it up as game.html ---
Copy-Item -LiteralPath $dst -Destination $game -Force

#--- 2. Restore the official website as index.html ---
git -C $r show "d2c9c5a:index.html" | Out-File -LiteralPath $dst -Encoding utf8

#--- 3. Patch stale references in the restored website ---
$t = Get-Content -LiteralPath $dst -Raw

# 3a. old apk name -> Vulkan apk (repo now ships Skibidi_Toilet_Defense_Vulkan.apk)
$t = $t -replace 'Skibidi_Toilet_Defense\.apk', 'Skibidi_Toilet_Defense_Vulkan.apk'

# 3b. stale canonical/og/twitter URLs pointing at the RENAMED -PC repo -> current WinOs URL
$t = $t -replace 'https://athallajovian9-cyber\.github\.io/Skibidi_Toilet_Defense-PC', 'https://athallajovian9-cyber.github.io/Skibidi_Toilet_Defense_WinOs'

# 3c. manifest ref -> relative file (manifest.json exists in repo)
$t = $t -replace 'href="https://athallajovian9-cyber\.github\.io/Skibidi_Toilet_Defense_WinOs/manifest\.json"', 'href="manifest.json"'

Set-Content -LiteralPath $dst -Value $t -Encoding utf8

#--- Report ---
$size = (Get-Item -LiteralPath $dst).Length
$gSize = (Get-Item -LiteralPath $game).Length
Write-Output "index.html restored website: $size bytes"
Write-Output "game.html preserved game:    $gSize bytes"
