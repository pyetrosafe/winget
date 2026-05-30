# Se a execução de Scripts está desabilitada, ou seja, está fechando a janela ou dando erro.
# Execute o comando "Set-ExecutionPolicy Unrestricted"
# no PowerShell como administrador e tente novamente.

param([switch]$Elevated)

# Mapa de chaves booleanas para cores
$Cor = @{
    $true  = 'Green'
    $false = 'Red'
}

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-ExecutionPolicy Unrestricted -NoProfile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    exit
}

function CheckWingetCommand {
    $found_winget = [bool] (Get-Command -ErrorAction Ignore -Type Application winget)
    return $found_winget
}

function DownloadInstallWinget {
    $winget_name = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    $installer_found = (Test-Path -Path ".\$winget_name")

    Write-Host "Verificando se já tem o instalador do winget.`n`n"
    Start-Sleep -Milliseconds 500

    $mesg = "Instalador do Winget" + $(if(!($installer_found)){ ' não' } ) + " encontrado!`n`n"
    Write-Host $mesg -ForegroundColor $Cor[$installer_found]
    Start-Sleep -Milliseconds 500

    if (!($installer_found)) {
        Write-Host "Baixando Winget (Windows Package Manager)! Aguarde...`n`n"
        Invoke-WebRequest "https://github.com/microsoft/winget-cli/releases/download/v1.9.1792-preview/$winget_name" -OutFile $winget_name
    }

    Write-Host "Abrindo instalador do Winget. Ao terminar volte aqui!`n`n"
    Start-Sleep -Milliseconds 700
    & ".\$winget_name"
}

# Cria um menu interativo para escolher o arquivo
function Show-Menu {
    param($ListaDeArquivos)

    $selectedIndex = 0

    # Imprime o cabeçalho apenas uma vez (fora do laço de repetição)
    Write-Host "`n=== SELECIONE A LISTA DE APLICATIVOS ===" -ForegroundColor Cyan
    Write-Host "Use as setas para CIMA e BAIXO para navegar e ENTER para escolher." -ForegroundColor Yellow

    # Salva a posição atual da linha em que o cursor está (eixo Y)
    $linhaInicial = [Console]::CursorTop

    while ($true) {
        # Posiciona o cursor de volta na linha inicial salva antes de desenhar as opções
        [Console]::SetCursorPosition(0, $linhaInicial)

        # Desenha as opções na tela, sobrescrevendo as anteriores
        for ($i = 0; $i -lt $ListaDeArquivos.Count; $i++) {
            # Os espaços extras no final garantem que o texto anterior seja totalmente coberto
            if ($i -eq $selectedIndex) {
                Write-Host " -> $($ListaDeArquivos[$i].Name)        " -ForegroundColor Green
            } else {
                Write-Host "    $($ListaDeArquivos[$i].Name)        "
            }
        }

        # Captura a tecla pressionada pelo usuário
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # Lógica de navegação
        if ($key -eq 38) {
            # Seta para CIMA
            $selectedIndex--
            if ($selectedIndex -lt 0) { $selectedIndex = $ListaDeArquivos.Count - 1 }
        } elseif ($key -eq 40) {
            # Seta para BAIXO
            $selectedIndex++
            if ($selectedIndex -ge $ListaDeArquivos.Count) { $selectedIndex = 0 }
        } elseif ($key -eq 13) {
            # Tecla ENTER
            # Pula o cursor para baixo do menu antes de retornar, para não atrapalhar os próximos prints
            $linhaFinal = $linhaInicial + $ListaDeArquivos.Count
            [Console]::SetCursorPosition(0, $linhaFinal)
            Write-Host "`n"

            return $ListaDeArquivos[$selectedIndex]
        }
    }
}

function GetAppsList {
    # Descobre a pasta onde este script está salvo
    $scriptDir = $PSScriptRoot
    $appsDir = Join-Path -Path $scriptDir -ChildPath "apps"

    # Verifica se a pasta 'apps' existe
    if (-not (Test-Path -Path $appsDir)) {
        Write-Host "ERRO: A pasta 'apps' não foi encontrada.`n" -ForegroundColor Red
        return $null
    }

    # Lê os arquivos de texto (.txt) dentro da pasta 'apps'[cite: 3]
    $arquivosDisponiveis = Get-ChildItem -Path $appsDir -Filter *.txt

    if ($arquivosDisponiveis.Count -eq 0) {
        Write-Host "ERRO: Nenhum arquivo .txt encontrado na pasta 'apps'.`n" -ForegroundColor Red
        return $null
    }

    # PREPARAÇÃO DO MENU: Criamos uma lista customizada de opções
    $opcoesMenu = @()

    # 1. Adicionamos todos os arquivos reais encontrados
    foreach ($arquivo in $arquivosDisponiveis) {
        $opcoesMenu += [PSCustomObject]@{
            Name = $arquivo.Name
            FullName = $arquivo.FullName
            IsAll = $false
        }
    }

    # 2. Adicionamos a opção extra no final da lista
    $opcoesMenu += [PSCustomObject]@{
        Name = "Todos arquivos"
        FullName = ""
        IsAll = $true
    }

    # Exibe o menu e guarda o arquivo escolhido
    $arquivoEscolhido = Show-Menu -ListaDeArquivos $opcoesMenu
    Write-Host "Iniciando a instalação da lista: $($arquivoEscolhido.Name)`n" -ForegroundColor Cyan

    $conteudoBruto = @()

    # Verifica se o usuário escolheu "Todos arquivos"
    if ($arquivoEscolhido.IsAll) {
        foreach ($arquivo in $arquivosDisponiveis) {
            $conteudoBruto += Get-Content $arquivo.FullName
        }
    } else {
        $conteudoBruto = Get-Content $arquivoEscolhido.FullName
    }

    # Lê o conteúdo do arquivo, ignora linhas vazias e linhas que começam com '#' (comentários)[cite: 3]
    # E remove duplicatas com o "Select-Object -Unique"
    return $conteudoBruto | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#' } | Select-Object -Unique
}

function InstallByWinget {
    if (CheckWingetCommand) {

        Write-Host "Caso algum programa da lista já esteja instalado, o que deseja fazer?`n" -ForegroundColor Cyan
        Write-Host "[A]tualizar (Instala a versão mais recente por cima)"
        Write-Host "[M]anter (Ignora a instalação se o programa já existir)`n"
        Write-Host "Escolha: " -NoNewLine

        do {
            $escolhaAtualizacao = [Console]::ReadKey($true).KeyChar.ToString().ToUpper()
        } while ($escolhaAtualizacao -notmatch "^[AM]")
        Write-Host "$escolhaAtualizacao`n" -ForegroundColor Yellow

        $conteudoLista = GetAppsList

            # Encerra execução caso lista é nula OU se a quantidade de itens é zero (caso o .txt não tenha IDs válidos)
        if ($null -eq $conteudoLista -or $conteudoLista.Length -eq 0) {
            Write-Host "`nNenhum aplicativo para instalar." -ForegroundColor Red
            return
        }

            # Loop para instalar cada aplicativo da lista
        foreach ($appId in $conteudoLista) {
            $appIdLimpo = $appId.Trim()

            if ($escolhaAtualizacao -eq 'M') {
                Write-Host "Verificando: $appIdLimpo ... " -NoNewLine -ForegroundColor DarkGray

                # Executa o 'winget list'. O "2>&1" captura qualquer saída para a variável
                $checkInstall = winget list -e --id=$appIdLimpo 2>&1
                # Se a saída contiver o ID procurado, o app já está no sistema
                if ($checkInstall -match [regex]::Escape($appIdLimpo)) {
                    Write-Host "---> Já instalado. Mantendo versão atual.`n" -ForegroundColor DarkGreen
                    continue
                }

                Write-Host "---> Não encontrado.`n" -ForegroundColor DarkGray
            }

            Write-Host "Instalando: $appIdLimpo ...`n" -ForegroundColor Yellow

            # Comando de instalação
            winget install --accept-source-agreements --accept-package-agreements -e --id=$appIdLimpo
        }
    }
    else {
        Write-Host "`rComando winget não encontrado.`nÉ necessário instalar Winget`n"  -NoNewLine -ForegroundColor Red
        Write-Host "`rQuer tentar baixar e/ou instalar novamente? [S]im : [N]ão" -NoNewLine
        do {
            $key = [Console]::ReadKey($true).KeyChar.ToString().ToUpper()
            Start-Sleep -Milliseconds 300
        }
        while ($key -notmatch "^[SsNn]")
        Write-Host "`n`n$key`n`n"
        Start-Sleep -Seconds 1

        if ($key -match "^[Ss]") {
            MainProcessWinget
        }
    }
}

function CheckWingetInstalled {
    Write-Host "Verificando se winget já está instalado!`n"
    Start-Sleep -Milliseconds 500

    $found_winget = CheckWingetCommand

    $mesg = "Winget" + $(if(!($found_winget)){ ' não' } ) + " encontrado!`n"
    Write-Host $mesg -ForegroundColor $Cor[$found_winget]
    Start-Sleep -Milliseconds 500

    return $found_winget
}

function MainProcessWinget {
    if (!(CheckWingetInstalled)) {
        DownloadInstallWinget
        $key = "N"

        do {
            if ($key -match "^[Nn]") {
                Write-Host "`rTerminou a instalação? [S]im : [N]ão : [C]ancelar" -NoNewLine
            }

            $key = [Console]::ReadKey($true).KeyChar.ToString().ToUpper()
            Start-Sleep -Milliseconds 300

            if ($key -match "^[Nn]") {
                Write-Host "`n$key"
                Write-Host "`nVerifique a janela de instalação e se necessário aguarde mais um pouco enquanto termina de instalar.`n" -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
        while ($key -notmatch "^[SsCc]")

        Write-Host "`n$key`n"
        Start-Sleep -Milliseconds 300

        if ($key -match "^[Cc]") {
            FecharTerminal
        }
    }

    $repetir = $false
    do {
        InstallByWinget

        Write-Host "`n"
        Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=" -ForegroundColor Green
        Write-Host "=                                                             =" -ForegroundColor Green
        Write-Host "=          A instalação dos seus programas terminou.          =" -ForegroundColor Green
        Write-Host "=                                                             =" -ForegroundColor Green
        Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=" -ForegroundColor Green

        Write-Host "`nDeseja instalar outro preset (lista de apps)? [S]im / [N]ão " -ForegroundColor Yellow -NoNewLine
        $key = [Console]::ReadKey($true).KeyChar.ToString().ToUpper()
        Write-Host "`n$key`n"
        $repetir = $key -eq "S"
    } while ($repetir)

    # Finalizou
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=" -ForegroundColor Green
    Write-Host "=                                                             =" -ForegroundColor Green
    Write-Host "=" -ForegroundColor Green -NoNewLine
    Write-Host "             Obrigado por usar o automatizador!              " -ForegroundColor Yellow -NoNewLine
    Write-Host "=" -ForegroundColor Green
    Write-Host "=                                                             =" -ForegroundColor Green
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=" -ForegroundColor Green
    FecharTerminal
}

function FecharTerminal {
    Write-Host "`nPressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    [System.Environment]::Exit(0)
}

if ($elevated) {
    # Garante que está na pasta do script
    Set-Location -Path $PSScriptRoot

    Write-Host "Iniciando script de instalação com winget!`n" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 500

    MainProcessWinget
}
