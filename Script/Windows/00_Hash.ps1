# PowerShell 脚本开始
# PowerShell 脚本中添加 UTF-8 编码的注释
#encoding UTF-8
# 设置 CMD 窗口字符编码为 UTF-8
chcp 65001 | Out-Null

# 设置并发处理的最大线程数
$maxThreads = 8

# 定义显示动态进度条的函数
function Show-RainbowProgressBar {
    param (
        [int]$Percentage
    )

    $barLength = 69
    $progressCount = [math]::Round(($Percentage * $barLength) / 100)

    $colors = @("DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray",
            "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")

    $colorIndex = 0

    # 移动光标到进度条起始位置
    [Console]::SetCursorPosition(0, [Console]::CursorTop)

    # 输出进度条
    for ($i = 0; $i -lt $progressCount; $i += 2) {
        $char = "██"
        $color = $colors[$colorIndex]
        $colorIndex = ($colorIndex + 1) % $colors.Count
        Write-Host -NoNewline -ForegroundColor $color $char
    }

    # 输出空格覆盖进度条的剩余部分
    for ($i = $progressCount; $i -lt $barLength; $i += 2) {
        Write-Host -NoNewline "→"
    }

    # 输出百分比
    Write-Host -NoNewline -ForegroundColor "White" " [$Percentage%] "
}

$targetDirectory = $PWD.Path
$outputFilePath = Join-Path -Path $targetDirectory -ChildPath "Folder\Hash.json"

# 检查输出文件目录是否存在，如果不存在则创建它
$outputDirectory = Split-Path -Path $outputFilePath -Parent
if (-not (Test-Path -Path $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
    Write-Host "文件夹已创建成功: $outputDirectory 目录用来存放Hash.json文件"
}


# 写入 `[等等` 符号，如果文件不存在或者文件为空
if (-not (Test-Path -Path $outputFilePath)) {
    # 为了让代码逻辑简单 所以需要添加一个{}对象 不然后面还要改变代码逻辑
    # "[`n  {`n  }" | Out-File -FilePath $outputFilePath -Encoding utf8
    # 获取用户名
    $user = $env:USERNAME

    # 获取当前时间
    $currentTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"

    # 将用户名和当前时间插入到输出字符串中
    $outputString = "[`n  {`n    `"User`":  `"$user`",`n    `"Date`":  `"$currentTime`"`n  }"
    $outputString | Out-File -FilePath $outputFilePath -Encoding utf8
    
} elseif ((Get-Content -Path $outputFilePath -Raw) -eq $null) {
    # Write-Output "文件为空"
    # 为了让代码逻辑简单 所以需要添加一个{}对象 不然后面还要改变代码逻辑
    # "[`n  {`n  }" | Out-File -FilePath $outputFilePath -Encoding utf8
    # 获取用户名
    $user = $env:USERNAME

    # 获取当前时间
    $currentTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"

    # 将用户名和当前时间插入到输出字符串中
    $outputString = "[`n  {`n    `"User`":  `"$user`",`n    `"Date`":  `"$currentTime`"`n  }"
    $outputString | Out-File -FilePath $outputFilePath -Encoding utf8
}

# 如果文件已存在内容，则在写入之前处理末尾的`]`和换行符
if ((Get-Content -Path $outputFilePath -Raw) -ne $null) {
    $filecontent = Get-Content -Path $outputFilePath -Raw
    if ($filecontent.Length -gt 0) {
        $filecontent = $filecontent.TrimEnd("`r", "`n", "]")  # 去掉末尾的换行符和`]`
        Set-Content -Path $outputFilePath -Value $filecontent -Encoding utf8 -NoNewline
        # Write-Host "去除[符号成功"
    }
}


# 获取当前脚本所在的目录，包含后缀名
$currentDirectory = $PSScriptRoot

# 定义计算哈希值的函数
function Calculate-Hash {
    param (
        [string]$filePath
    )

    $hashAlgorithms = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512")

    $result = @{}

    # 文件创建时间、修改时间和访问时间
    # $creationTime = (Get-Item -LiteralPath $filePath).CreationTime
    # $lastWriteTime = (Get-Item -LiteralPath $filePath).LastWriteTime
    # $lastAccessTime = (Get-Item -LiteralPath $filePath).LastAccessTime
    # 获取更多文件属性 根据自己需求编写 ...
    # 文件所有者和 ACL 信息, 文件属性

    $fileSize = (Get-Item -LiteralPath $filePath).length  # 获取文件大小（字节数）
    # 计算字节数
    $result['FileSizeBytes'] = $fileSize
    # $result['文件创建时间'] = $creationTime.ToString()
    # $result['文件最后修改时间'] = $lastWriteTime.ToString()

    foreach ($algorithm in $hashAlgorithms) {
        $hashValue = (Get-FileHash -LiteralPath $filePath -Algorithm $algorithm).Hash.ToLower()
        $result[$algorithm] = $hashValue
    }

    $result
}

# 在作业中加载 Calculate-Hash 函数
$initScriptBlock = {
    function Calculate-Hash {
        param (
            [string]$filePath
        )

        $hashAlgorithms = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512")

        $result = @{}

        # 文件创建时间、修改时间和访问时间
        # $creationTime = (Get-Item -LiteralPath $filePath).CreationTime
        # $lastWriteTime = (Get-Item -LiteralPath $filePath).LastWriteTime
        # $lastAccessTime = (Get-Item -LiteralPath $filePath).LastAccessTime
        # 获取更多文件属性 根据自己需求编写 ...
        # 文件所有者和 ACL 信息, 文件属性

        $fileSize = (Get-Item -LiteralPath $filePath).length  # 获取文件大小（字节数）
        # 计算字节数
        $result['FileSizeBytes'] = $fileSize
        # $result['文件创建时间'] = $creationTime.ToString()
        # $result['文件最后修改时间'] = $lastWriteTime.ToString()

        foreach ($algorithm in $hashAlgorithms) {
            $hashValue = (Get-FileHash -LiteralPath $filePath -Algorithm $algorithm).Hash.ToLower()
            $result[$algorithm] = $hashValue
        }

        $result
    }
}

Write-Host "English: Do you want to recurse into subdirectories? (Y/N)"
$recurse = Read-Host "是否计算 子文件夹中文件的Hash值: (Y/N) [是的话：直接回车即可]"
# 将用户输入和比较值都转换为小写
$recurse = $recurse.ToLower()

Write-Host ""
Write-Host "--> Hash值正在计算中 Doing..."

Write-Host ""
Write-Host ""

# 遍历目标目录下的文件并计算哈希值
# 开始计时
$startTime = Get-Date
if ($recurse -eq 'y' -or $recurse -eq '') {
    $totalFiles = @(Get-ChildItem -Path $targetDirectory -File -Recurse | Where-Object { $_.Name -ne "HASH.txt" -and $_.Name -ne "00_Hash.ps1" -and $_.Name -ne "00__双击运行我即可.bat" }).Count
    $jobs = Get-ChildItem -Path $targetDirectory -File -Recurse | Where-Object { $_.Name -ne "HASH.txt" -and $_.Name -ne "00_Hash.ps1" -and $_.Name -ne "00__双击运行我即可.bat" } |
    ForEach-Object {
        $filePath = $_.FullName
        $fileName = $_.Name

        # 修改此处，将并发数限制为$maxThreads
        while ((Get-Job -State Running).Count -ge $maxThreads) {
            Start-Sleep -Milliseconds 100
        }

        $scriptBlock = {
            param ($filePath, $fileName)
            
            # 定义计算哈希值的函数
            function Calculate-Hash {
                param (
                    [string]$filePath
                )

                $hashAlgorithms = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512")

                $result = @{}

                #文件创建时间、修改时间和访问时间
                # $creationTime = (Get-Item -LiteralPath $filePath).CreationTime
                # $lastWriteTime = (Get-Item -LiteralPath $filePath).LastWriteTime
                # $lastAccessTime = (Get-Item -LiteralPath $filePath).LastAccessTime
                # 获取更多文件属性 根据自己需求编写 ...
                # 文件所有者和 ACL 信息, 文件属性

                $fileSize = (Get-Item -LiteralPath $filePath).length  # 获取文件大小（字节数）
                # 计算字节数
                $result['FileSizeBytes'] = $fileSize
                # $result['文件创建时间'] = $creationTime.ToString()
                # $result['文件最后修改时间'] = $lastWriteTime.ToString()

                foreach ($algorithm in $hashAlgorithms) {
                    $hashValue = (Get-FileHash -LiteralPath $filePath -Algorithm $algorithm).Hash.ToLower()
                    $result[$algorithm] = $hashValue
                }

                $result
            }
            
            # 在作业中使用 $using: 来引用外部的变量
            $hashResults = Calculate-Hash -filePath $using:filePath
            $hashResults['FileName'] = $using:fileName

    # 将结果写入文件
    $hashResults | ConvertTo-Json -Depth 10 | ForEach-Object {
        
        # 添加当前 JSON 对象，并换行，并在每个对象之前添加一个空格缩进
        $content = ", `n  $_"
        
        # 添加缩进到对象结束符号之前
        $content = $content -replace "}", "  }"

        # 追加处理后的内容到文件末尾
        Add-Content -Path $using:outputFilePath -Value $content -Encoding utf8 -NoNewline
    } | Out-Null





        }

        $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $filePath, $fileName
        $job

        # 增加索引
        $index++
        # 计算进度百分比并展示动态进度条
        $progressPercentage = [math]::Round(($index / $totalFiles) * 100)
        # 隐藏光标
        [System.Console]::CursorVisible = $false
        Show-RainbowProgressBar -Percentage $progressPercentage
        # 显示光标
        [System.Console]::CursorVisible = $true
    }

    # 等待所有作业完成
    $null = $jobs | Wait-Job

    # 获取作业结果（这里不再需要）
    # $results = $jobs | Receive-Job

} else {
    $totalFiles = @(Get-ChildItem -Path $targetDirectory -File | Where-Object { $_.Name -ne "HASH.txt" -and $_.Name -ne "00_Hash.ps1" -and $_.Name -ne "00__双击运行我即可.bat" }).Count
    $jobs = Get-ChildItem -Path $targetDirectory -File | Where-Object { $_.Name -ne "HASH.txt" -and $_.Name -ne "00_Hash.ps1" -and
        $_.Name -ne "00__双击运行我即可.bat" } |
        ForEach-Object {
            $filePath = $_.FullName
            $fileName = $_.Name

            # 修改此处，将并发数限制为$maxThreads
            while ((Get-Job -State Running).Count -ge $maxThreads) {
                Start-Sleep -Milliseconds 100
            }

            $scriptBlock = {
                param ($filePath, $fileName)
                
                # 定义计算哈希值的函数
                function Calculate-Hash {
                    param (
                        [string]$filePath
                    )

                    $hashAlgorithms = @("MD5", "SHA1", "SHA256", "SHA384", "SHA512")

                    $result = @{}

                    #文件创建时间、修改时间和访问时间
                    # $creationTime = (Get-Item -LiteralPath $filePath).CreationTime
                    # $lastWriteTime = (Get-Item -LiteralPath $filePath).LastWriteTime
                    # $lastAccessTime = (Get-Item -LiteralPath $filePath).LastAccessTime
                    # 获取更多文件属性 根据自己需求编写 ...
                    # 文件所有者和 ACL 信息, 文件属性

                    $fileSize = (Get-Item -LiteralPath $filePath).length  # 获取文件大小（字节数）
                    # 计算字节数
                    $result['FileSizeBytes'] = $fileSize
                    # $result['文件创建时间'] = $creationTime.ToString()
                    # $result['文件最后修改时间'] = $lastWriteTime.ToString()

                    foreach ($algorithm in $hashAlgorithms) {
                    $hashValue = (Get-FileHash -LiteralPath $filePath -Algorithm $algorithm).Hash.ToLower()
                        $result[$algorithm] = $hashValue
                    }

                    $result
                }

                # 在作业中使用 $using: 来引用外部的变量
                $hashResults = Calculate-Hash -filePath $using:filePath
                $hashResults['FileName'] = $using:fileName

    # 将结果写入文件
    $hashResults | ConvertTo-Json -Depth 10 | ForEach-Object {

        # 添加当前 JSON 对象，并换行，并在每个对象之前添加一个空格缩进
        $content = ", `n  $_"

        # 添加缩进到对象结束符号之前
        $content = $content -replace "}", "  }"
        
        # 追加处理后的内容到文件末尾
        Add-Content -Path $using:outputFilePath -Value $content -Encoding utf8 -NoNewline
    } | Out-Null


    
            }

            $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $filePath, $fileName
            $job

            # 增加索引
            $index++
            # 计算进度百分比并展示动态进度条
            $progressPercentage = [math]::Round(($index / $totalFiles) * 100)
            # 隐藏光标
            [System.Console]::CursorVisible = $false
            Show-RainbowProgressBar -Percentage $progressPercentage
            # 显示光标
            [System.Console]::CursorVisible = $true
        }

    # 等待所有作业完成
    $null = $jobs | Wait-Job

    # 获取作业结果（这里不再需要）
    # $results = $jobs | Receive-Job
}

# 结束计时
$endTime = Get-Date
$elapsedTime = $endTime - $startTime


Write-Host "`n"
Write-Host "--> 计算Hash值耗时: $($elapsedTime.Hours)小时: $($elapsedTime.Minutes)分钟: $($elapsedTime.Seconds)秒: $($elapsedTime.Milliseconds)毫秒"

Write-Host "--> Hash值已计算完成 Done...  --> 文件总数：$totalFiles"
Write-Host "--> Hash.json文件已保存到: $outputFilePath"

# 清理作业
$jobs | Remove-Job

# 添加换行符和] 符号
Add-Content -Path $outputFilePath -Value "`n]"

$CopyoutputFilePath = Join-Path -Path $targetDirectory -ChildPath "Folder\Hash.txt"

# 复制文件
Copy-Item -Path $outputFilePath -Destination $CopyoutputFilePath -Force

# 检查是否复制成功
if (Test-Path $outputFilePath) {
} else {
    Write-Output "File copy failed."
}

Write-Host ""
Write-Host ""
# 等待用户按下任意键，保持窗口打开
Write-Host "--> 按下任意键继续..." -NoNewline
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
Write-Host ""
# PowerShell 脚本结束
