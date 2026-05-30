# ![WinGet Icon](https://raw.githubusercontent.com/microsoft/winget-cli/refs/heads/master/.github/images/WindowsPackageManager_Assets/ICO/PNG/_40.png) Winget

Este projeto automatiza a instalação de programas após formatar o Windows (10 ou 11), usando o Windows Package Manager (`winget`).

## Visão Geral do Windows Package Manager

O [Winget](https://github.com/microsoft/winget-cli) é a ferramenta oficial de linha de comando para interagir com o [Windows Package Manager](https://learn.microsoft.com/pt-br/windows/package-manager/winget/), que é um gerenciador de pacotes gratuito e de código aberto projetado pela Microsoft para Windows 10 e posteriores.

Usando o Winget, a partir de um comando, é possível instalar pacotes oficias:

    winget install <package>

Este repositório oferece um script auxiliar que baixa/ativa o winget quando necessário e instala conjuntos de aplicações automatizados chamados "presets".

## Vantagens

1. Tempo - Automatização do processo, economiza horas de pesquisa e cliques.
2. Segurança - Evita baixar instaladores com vírus, de sites duvidosos; tudo vem direto dos repositórios oficiais.
3. Zero Bloatware - O script instala apenas o que você pediu, sem aquelas barrinhas de pesquisa indesejadas no navegador.

- Download e instalação automática do `winget` caso não esteja presente.
    - Algumas versões do Windows 10 recém formatado, o comando winget não está disponível, pois não vem pré instalado.
    - Esse automatizador fará verificação se o winget está presente, se não estiver faz o download do Winget automaticamente e abre o instalador ao terminar. Facilitando esse passo para o usuário não ter que fazer manualmente.
- Instalação automatizada e em sequência de uma lista customizada de programas.


## Mudanças recentes

- O script principal foi renomeado de `Default Apps Install on New Windows.ps1` para `winget-script.ps1`.
- A refatoração separou as listas de apps do código principal: agora os presets ficam na pasta `apps/` como arquivos de texto.
- É possível selecionar um preset para executar, executar todos, ou navegar por um menu interativo que lista os presets disponíveis.
- Ao instalar, o script verifica se o aplicativo já está instalado; dependendo da opção escolhida, ele tentará atualizar/instalar ou pulará para manter a versão atual.
- Ao concluir a execução de um preset, o script pergunta se você quer executar outro preset em sequência ou sair.
- Foi adicionado um arquivo `.bat` (`Winget Installer.bat`) para usuários que preferem executar por duplo clique sem abrir o PowerShell manualmente.

## Estrutura

- `winget-script.ps1` — script principal (PowerShell).
- `Winget Installer.bat` — atalho para executar o script via duplo clique no Windows.
- `apps/` — pasta com presets (cada arquivo de texto é uma lista de comandos/IDs para `winget`).

Exemplo de presets já incluídos:

- `Basico.txt` - Programas para usuários comuns
- `Desenvolvedor de Software.txt` - Programas para desenvolvedores
- `Editor Fotos e Videos.txt` - Programas para criadores/editores de fotos/vídeos
- `Gamer.txt` - Programas para jogadores
- `Microsoft Visual C++ Redistribustable.txt` - Bibliotecas de recursos do Windows úteis para todos tipos de usuários, utilizados por outros programas como jogos/editores;

## Como usar

1. Download
    Faça o download do projeto compactado e extraia os arquivos após o download.

2. Criar/Editar lista de apps
    Crie, edite ou remova os arquivos na pasta àpps`, adicione ou remova o nome dos programas que você deseja que sejam instalados automaticamente.

    Insira o id de cada programa em linhas separadas.

3. Executando
    Dê um duplo clique em `Winget Installer.bat` ou clique com o botão direito sobre `winget-script.ps1` e selecione "Executar com o PowerShell".

O script exibirá um menu com os presets disponíveis. Você pode:

- Escolher um preset específico para executar.
- Executar todos os presets sequencialmente.
- Sair sem executar nada.

Durante a execução, para cada item o script verifica se o aplicativo já está presente e age conforme sua escolha (instalar/atualizar ou pular para manter a versão atual).

Ao finalizar um preset, será perguntado se você deseja executar outro preset.

### Executando com linha de comando

1. Abra o PowerShell como Administrador.

2. (Opcional) Permita execução de scripts se necessário:

    `Set-ExecutionPolicy Unrestricted`

3. Execute o script principal:

    `& '<caminho\para\winget-script.ps1>'`

## Como editar ou criar presets

1. Abra um dos arquivos em `apps/` com um editor de texto.
2. Cada linha deve conter um comando `winget` ou apenas o ID do pacote (o script aceita formatos comuns usados nos presets).
3. Salve o arquivo. O menu do script detectará automaticamente novos arquivos na próxima execução.

## Encontrar IDs de pacotes

Use `winget search <nome>` ou pesquise em https://winget.run para localizar os IDs dos pacotes.

## Observações

- O script tenta baixar e instalar o `winget` quando ele não está presente, mas o comportamento pode variar conforme a versão do Windows.

    - Download e instalação do winget

        - Assim que terminar o download, clique no botão Atualizar, na janela de instalação que se abrir. Quando finalizar, feche a janela e volte ao PowerShell.
        - Digite "S" para pergunta: `Terminou a instalação? [S]im : [N]ão : [C]ancelar`.

- Teste em uma máquina de preparo antes de executar em ambientes críticos.

## Sugestão
Guarde esse projeto em um USB flash drive (pendrive), ou na nuvem, e edite os presets sempre que quiser adicionar ou remover pacotes.

## Contribuições

Sinta-se à vontade para abrir issues ou enviar pull requests com novos presets ou melhorias no script.