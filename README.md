# ![WinGet Icon](https://github.com/microsoft/winget-cli/blob/master/.github/images/WindowsPackageManager_Assets/ICO/PNG/_40.png) Winget

Este projeto foi feito para automatizar ainda mais a instalação de programas após formatar o Windows (10 ou 11).

## Visão Geral do Windows Package Manager

O [Winget](https://github.com/microsoft/winget-cli), ou [Windows Package Manager](https://learn.microsoft.com/pt-br/windows/package-manager/winget/), é um gerenciador de pacotes gratuito e de código aberto projetado pela Microsoft para Windows 10 e Windows 11.

Consiste em um utilitário de linha de comando e um conjunto de serviços para instalar aplicativos.

Usando o Winget, a partir de um comando, você pode instalar seus pacotes favoritos:

    winget install <package>

## Indo além

Porém ao formatar o Windows (10, não foi testado se o Windows 11 já vem com o Winget), não dá para executar o comando winget, pois não vem pré instalado.
Os comandos disponibilizados no arquivo desse projeto, fará o download do Winget automaticamente.
Será necessário bem menos passos para automatizar tudo.

## Como proceder

Faça o download do arquivo [Default Apps Install on New Windows.ps1](./Default Apps Install on New Windows.ps1).
Edite o arquivo, adicione ou remova os programas que você deseja instalar automaticamente. Para isso, encontre as linhas com ```winget install ...```.

### Remover comandos de pacotes originais

Esse projeto trás três linhas de comando do winget para instalar os seguintes programas: Google Chrome, Notepad++ e WinRAR.

Caso não queira algum ou todos, basta remover as linhas com o ID desses programas.

### Adicionar novos pacotes para instalar

Adicione novas linhas alterando apenas o ID do programa, para um que você deseja instalar.

Use o comando abaixo como exemplo:

    winget install --accept-source-agreements --accept-package-agreements -e --id=Google.Chrome;

Para achar os IDs de outros programas, pode pesquisar no site [Winget RUN](https://winget.run).

O lugar correto para adicionar as linha de comandos, é abaixo das linhas com o texto a seguir:

    function InstallByWinget {
        if (CheckWingetCommand) {

### Executando o código

Para executar o código, abra o PowerShell como Administrador.

Agora libere a permissão para executar os comandos com o comando:

    Set-ExecutionPolicy Unrestricted

Agora copie o caminho do arquivo que você baixou e editou. No PowerShell digite ``` & '<caminho do arquivo>'``` e pressione Enter. Exemplo:

    PS C:\Windows\system32> & 'C:\Users\Pyetro\Desktop\Default Apps Install on New Windows.ps1'

Assim que terminar de baixar o Winget, clique no botão Atualizar, da janela de instalação do Windows. Quando finalizar, feche a janela e volte ao PowerShell.

Digite "S" para pergunta: ```Terminou a instalação? [S]im : [N]ão : [C]ancelar```. E aguarde os programas que você adicionou no arquivo serem instalados automaticamente.

Assim que terminar tudo, feche o PowerShell.

### Dica
Guarde esse arquivo no seu Pendrive, ou na nuvem, e edite ele sempre que quiser adicionar ou remover pacotes.
