<#
.SYNOPSIS
将当前文件夹下所有 .txt 文件转换为 ANSI (GBK) 编码（不备份）。
自动识别：仅当文件是有效的 UTF-8（有/无 BOM）时转换；若已是 ANSI 则跳过。
#>

$targetDir = Get-Location
Write-Host "处理目录: $targetDir" -ForegroundColor Cyan

$files = Get-ChildItem -Path $targetDir -Filter "*.txt" -File
if ($files.Count -eq 0) {
    Write-Host "未找到任何 .txt 文件。" -ForegroundColor Red
    exit
}

$ansi = [System.Text.Encoding]::Default
Write-Host "目标编码: $($ansi.EncodingName) (代码页 $($ansi.CodePage))" -ForegroundColor Yellow
Write-Host "警告：将直接覆盖原文件，不会创建备份！" -ForegroundColor Red
$confirm = Read-Host "是否继续？(y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "已取消操作。" -ForegroundColor Cyan
    exit
}

$total = $files.Count
$count = 0
$successCount = 0
$skipCount = 0
$failCount = 0

foreach ($file in $files) {
    $count++
    Write-Progress -Activity "转换为 ANSI" -Status "处理: $($file.Name)" -PercentComplete (($count / $total) * 100)

    try {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)

        # ----------------- 1. 检查是否为 UTF-8 with BOM -----------------
        $isUtf8Bom = $false
        $contentBytes = $bytes
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $isUtf8Bom = $true
            $contentBytes = $bytes[3..($bytes.Length-1)]   # 去掉 BOM
            Write-Host "[$count/$total] $($file.Name) : 检测到 UTF-8 (带 BOM)" -ForegroundColor Gray
        }

        if ($isUtf8Bom) {
            # 带 BOM 的 UTF-8 → 直接转换
            $content = [System.Text.Encoding]::UTF8.GetString($contentBytes)
            [System.IO.File]::WriteAllText($file.FullName, $content, $ansi)
            Write-Host "  -> 已从 UTF-8 (BOM) 转换为 ANSI" -ForegroundColor Green
            $successCount++
            continue
        }

        # ----------------- 2. 检查是否为有效的 UTF-8 (无 BOM) -----------------
        # 尝试用 UTF-8 解码
        $utf8String = [System.Text.Encoding]::UTF8.GetString($bytes)

        # 检查解码结果中是否包含 Unicode 替换字符 (U+FFFD)
        $hasReplacementChar = $utf8String.Contains([char]::ConvertFromUtf32(0xFFFD))

        if (-not $hasReplacementChar) {
            # 没有替换字符，再检查重新编码后是否与原字节完全一致
            $reencodedBytes = [System.Text.Encoding]::UTF8.GetBytes($utf8String)
            if (($bytes.Length -eq $reencodedBytes.Length) -and (Compare-Object $bytes $reencodedBytes -SyncWindow 0) -eq $null) {
                # 是有效的 UTF-8 (无 BOM)
                Write-Host "[$count/$total] $($file.Name) : 检测到 UTF-8 (无 BOM)" -ForegroundColor Gray
                [System.IO.File]::WriteAllText($file.FullName, $utf8String, $ansi)
                Write-Host "  -> 已从 UTF-8 转换为 ANSI" -ForegroundColor Green
                $successCount++
                continue
            }
        }

        # ----------------- 3. 其他情况（已是 ANSI 或无法识别的编码）→ 跳过 -----------------
        Write-Host "[$count/$total] $($file.Name) : 已是 ANSI 或其他非 UTF-8 编码，跳过" -ForegroundColor Gray
        $skipCount++
    }
    catch {
        Write-Host "  -> 处理失败: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n处理完成。成功转换: $successCount, 跳过: $skipCount, 失败: $failCount" -ForegroundColor Cyan