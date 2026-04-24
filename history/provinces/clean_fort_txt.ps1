# 判断一个字节数组是否为合法的 UTF-8（无 BOM）序列
function IsUtf8NoBom($bytes) {
    try {
        $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
        $text = $utf8.GetString($bytes)
        # 再编码回去，对比是否完全一致
        $reencoded = $utf8.GetBytes($text)
        if ($reencoded.Length -ne $bytes.Length) { return $false }
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($reencoded[$i] -ne $bytes[$i]) { return $false }
        }
        return $true
    } catch {
        return $false
    }
}

# 获取文件的真实编码（BOM 优先，无 BOM 则检测是否为合法 UTF-8，否则回退系统 ANSI）
function Get-FileEncoding($path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 2) {
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { return [System.Text.Encoding]::UTF8 }
        if ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) { return [System.Text.Encoding]::Unicode }
        if ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) { return [System.Text.Encoding]::BigEndianUnicode }
    }
    # 无 BOM：检测是否为合法的 UTF-8
    if (IsUtf8NoBom $bytes) {
        Write-Host "检测到 UTF-8 无 BOM: $path"
        return [System.Text.UTF8Encoding]::new($false)
    } else {
        Write-Host "检测到 ANSI (系统默认): $path"
        return [System.Text.Encoding]::Default
    }
}

Get-ChildItem -Path . -Filter *.txt | ForEach-Object {
    $file = $_
    $enc = Get-FileEncoding $file.FullName

    # 读取原始文本和换行符
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $originalText = $enc.GetString($bytes)

    # 检测换行符类型
    if ($originalText -match "`r`n") { $nl = "`r`n" }
    elseif ($originalText -match "(?<!\r)\n") { $nl = "`n" }
    else { $nl = "`r" }

    # 按行拆分，删除 fort2~6 = yes 的整行
    $lines = $originalText -split "`r`n|`n|`r"
    $newLines = $lines | Where-Object {
        $_ -notmatch '^\s*fort[2-6]\s*=\s*yes\s*$'
    }
    $newText = $newLines -join $nl

    # 保留原文件末尾的换行符
    if ($originalText.EndsWith("`r`n") -or $originalText.EndsWith("`n") -or $originalText.EndsWith("`r")) {
        $newText += $nl
    }

    if ($newText -ne $originalText) {
        Write-Host "已修改: $($file.Name) (编码: $($enc.EncodingName))"
        $newBytes = $enc.GetBytes($newText)
        [System.IO.File]::WriteAllBytes($file.FullName, $newBytes)
    } else {
        Write-Host "跳过(无变化): $($file.Name)"
    }
}
Write-Host "完成！"