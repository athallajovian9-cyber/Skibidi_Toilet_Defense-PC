$L = New-Object System.Collections.Generic.List[string]
$site = "C:\Users\RDC\Downloads\skibidi-defense-site"
# The last pure-website commit (before the game overwrote index.html) = the "official website" release.
# 3de2f98b "feat(website): prominently feature ... Vulkan APK in nav, hero, and download cards" -- 09-13 16:55,
# but the VISUAL/SEO-complete website is f44031777 (31,854B, 09-12 14:37: "Vulkan download button"+SEO).
# Pick the LAST commit that is a WEBSITE (size < 40KB) touching index.html, in date order:
$L.Add("=== preserving the game first ===")
$game = git -C $site rev-parse "HEAD:index.html"
$L.Add("  HEAD(game) blob = $game  size=" + (git -C $site cat-file -s $game))
# find website commits in order
$web = @("f44031777","3de2f98b","0a0db1dd","d2c9c5a4","87486c7","305439a","261ffbd","3c0e620","62460b03")
$target = "f44031777"  # the "official website" release w/ Vulkan download, SEO, Discord — best landing
$L.Add("  restoring website from commit $target")
$idx = git -C $site show "$target:index.html" 2>$null
$idxBytes = [Text.Encoding]::UTF8.GetBytes($idx)
$L.Add("  website bytes = " + $idxBytes.Length)
$L.Add("  first lines:")
foreach($fl in (($idx -split "`r?`n") | Select-Object -First 6)){ $L.Add("    " + $fl.Substring(0, [Math]::Min(90, $fl.Length))) }
# write to worktree
Set-Content -Path (Join-Path $site "index_website_backup.html") -Value $idx -Encoding UTF8 -NoNewline
$L.Add("  backup saved as index_website_backup.html in worktree")
$L | Set-Content -Encoding UTF8 "$env:TEMP\opencode\website_restore_stage1.txt"
$L | ForEach-Object { $_ }
