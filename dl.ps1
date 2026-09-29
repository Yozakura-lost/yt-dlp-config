$ytdlpversion = yt-dlp --version
$version = "2026.09.29"

$option = Get-Content "$PSScriptRoot\option.json" -Raw | ConvertFrom-Json
$dlmp4 = "bestvideo[ext=mp4][vcodec^=avc1]+bestaudio[ext=m4a]/bestvideo[ext=mp4][vcodec^=avc1]+bestaudio[ext=mp4]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo[ext=mp4]+bestaudio[ext=mp4]/b[ext=mp4]/best"
$dlmkv = "bestvideo+bestaudio/best"
$dlmp3 = "bestaudio/best"
$dlaac = "bestaudio[ext=m4a]/bestaudio/best"
$dlm4a = "bestaudio[ext=m4a]/bestaudio"
$dlflac = "bestaudio/best"
$dlopus = "bestaudio[ext=webm]/bestaudio/best"
$dlwav = "bestaudio/best"

Write-Host "yt-dlpバージョン     : $ytdlpversion"
Write-Host "ツールバージョン     : $version"
Write-Host "PATH                 :"$option.path
Write-Host "EXT                  :"$option.ext
Write-Host "FileName             :"$option.'file-name'
Write-Host "FormatOption         :"
Write-Host " --windows-filenames :"$option.'windows-filenames'
Write-Host " --add-metadata      :"$option.'add-metadata'
Write-Host " --embed-thumbnail   :"$option.'embed-thumbnail'
Write-Host " --custom-options    :"$option.'custom-options'

function start-dl {
	Write-Host "[?]動画のURLを入力してください: " -NoNewLine -ForegroundColor Green
	$inputURL = Read-Host
	if ($inputURL -eq "n") {
		exit
	} elseif (!$inputURL) {
		Write-Host "[!] URLが入力されていません" -ForegroundColor Red
		start-dl
	}
	
	$dlArgs = @("--no-warnings")
	if ($option.'windows-filenames' -eq $true) { $dlArgs += "--windows-filenames" }
	switch ($option.ext) {
		".mp4" {
			$dlArgs +=
			"-f", "$($dlmp4)",
			"-P", "$($option.path)\mp4"
		}
		".mkv" {
			$dlArgs +=
			"-f", "$($dlmkv)",
			"-P", "$($option.path)\mkv"
		}
		"bv+ba" {
			$dlArgs +=
			"-f", "$($dlmkv)",
			"-P", "$($option.path)\bv+ba"
		}
		".mp3" {
			$dlArgs +=
			"-f", "$($dlmp3)", "-x", "--audio-format", "mp3", "--audio-quality", "0",
			"-P", "$($option.path)\mp3"
		}
		".aac" {
			$dlArgs +=
			"-f", "$($dlaac)", "-x", "--audio-format", "aac", "--audio-quality", "0",
			"-P", "$($option.path)\aac"
		}
		".m4a" {
			$dlArgs +=
			"-f", "$($dlm4a)",
			"-P", "$($option.path)\aac"
		}
		".flac" {
			$dlArgs +=
			"-f", "$($dlflac)", "-x", "--audio-format", "flac",
			"-P", "$($option.path)\flac"
		}
		".opus" {
			$dlArgs +=
			"-f", "$($dlopus)", "-x", "--audio-format", "opus",
			"-P", "$($option.path)\opus"
		}
		".wav" {
			$dlArgs +=
			"-f", "$($dlwav)", "-x", "--audio-format", "wav",
			"-P", "$($option.path)\wav"
		}
		"ba" {
			$dlArgs +=
			"-f", "$($dlwav)",
			"-P", "$($option.path)\ba"
		}

	}
	
	if ($option.'add-metadata' -eq $true) { $dlArgs += "--add-metadata" }
	if ($option.'embed-thumbnail' -eq $true) { $dlArgs += "--embed-thumbnail", "--convert-thumbnails", "jpg" }
	if ($option.'custom-options') { $dlArgs += $option.'custom-options' -split',\s*' | Where-Object { $_ -ne "" }}
	$dlArgs += "-o", "$($option.'file-name')"

	yt-dlp.exe $dlArgs $inputURL
	$inputURL = ""
	
	Write-Host "[?]続けて別の動画をダウンロードしますか？ (y/n):" -NoNewLine -ForegroundColor Blue
	$QRetry = Read-Host
	if ($QRetry -eq "n") {
		exit
	} else {
		$QRetry = ""
		start-dl
	}
}

start-dl

pause