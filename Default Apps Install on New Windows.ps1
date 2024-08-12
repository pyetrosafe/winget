cd $env:userprofile\Downloads
# $policy_original = (Get-ExecutionPolicy)
# Set-ExecutionPolicy Unrestricted

function CheckWingetCommand {
    $found_winget = [bool] (Get-Command -ErrorAction Ignore -Type Application winget)
    return $found_winget
}

function DownloadInstallWinget {
    $winget_name = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    $installer_found = (Test-Path -Path ".\$winget_name")

    Write-Host "Verificando se já tem o instalador do winget."
    Start-Sleep -Milliseconds 500

    $mesg = "Instalador do Winget" + $(if(!($installer_found)){ ' não' } ) + " encontrado!"
    Write-Host $mesg
    Start-Sleep -Milliseconds 500

    if (!($installer_found)) {
        Write-Host "Baixando Winget (Windows Package Manager)! Aguarde..."
        Invoke-WebRequest "https://github.com/microsoft/winget-cli/releases/download/v1.9.1792-preview/$winget_name" -OutFile $winget_name
    }

    Write-Host "Abrindo instalador do Winget. Ao terminar volte aqui!"
    Start-Sleep -Milliseconds 700
    & ".\$winget_name"
}

function InstallByWinget {
    if (CheckWingetCommand) {
        winget install --accept-source-agreements --accept-package-agreements -e --id=Google.Chrome;
        winget install --accept-source-agreements --accept-package-agreements -e --id=Notepad++.Notepad++;
        winget install --accept-source-agreements --accept-package-agreements -e --id=RARLab.WinRAR;
    }
    else {
        $tentarNovamente = $(Read-Host -Prompt "Comando winget não encontrado.`nÉ necessário instalar Winget.`nQuer tentar baixar e/ou installar novamente? [S]im : [N]ão")
        Start-Sleep -Milliseconds 300
        if ($tentarNovamente -eq "S") {
            MainProcessWinget
        }
    }
}

function CheckWingetInstalled {
    Write-Host "Verificando se winget já está instalado!"
    Start-Sleep -Milliseconds 500

    $found_winget = CheckWingetCommand

    $mesg = "Winget" + $(if(!($found_winget)){ ' não' } ) + " encontrado!"
    Write-Host $mesg
    Start-Sleep -Milliseconds 500

    return $found_winget
}

function MainProcessWinget {

    if (!(CheckWingetInstalled)) {
        DownloadInstallWinget
        $question = 'Terminou a instalação? [S]im : [N]ão : [C]ancelar'
        $installEnds = $(Read-Host -Prompt $question)
        while ($installEnds -eq "N") {
            Start-Sleep -Seconds 1
            $installEnds = $(Read-Host -Prompt $question)
        }
        if ($installEnds -eq "S") {
            InstallByWinget
        }
    } else {
        InstallByWinget
    }
}

Write-Host "Iniciando script de instalação com winget!"
Start-Sleep -Milliseconds 500

MainProcessWinget

# Set-ExecutionPolicy $policy_original
