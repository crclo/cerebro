# ============================================================
#  Cerebro - instalador para Windows (PowerShell)
#  https://cesarcampos.com.br/cerebro
#
#  Monta uma pasta de trabalho para o agente de IA que voce
#  JA TEM instalado (Claude Code, Codex CLI ou Gemini CLI).
#
#  Este script nao instala IA nenhuma, nao pede senha,
#  nao coleta dado e nao manda nada para lugar nenhum.
#  Ele so cria pastas e arquivos de texto na sua maquina.
#
#  Leia antes de rodar. Serio. Sempre.
# ============================================================

function Install-Cerebro {
    param(
        [switch]$DryRun,
        [string]$Dir = "",
        [string]$Cli = "",
        [switch]$NoShortcut,
        [switch]$NoLaunch
    )

    $ErrorActionPreference = "Stop"
    $repoUser   = "crclo"
    $repoName   = "cerebro"
    $repoBranch = "main"
    $versao     = "1.0.0"

    function Tit($t)  { Write-Host ""; Write-Host $t -ForegroundColor Cyan }
    function Ok($t)   { Write-Host "  OK  " -ForegroundColor Green -NoNewline; Write-Host $t }
    function Warn($t) { Write-Host "  !   " -ForegroundColor Yellow -NoNewline; Write-Host $t }
    function Err($t)  { Write-Host "  X   " -ForegroundColor Red -NoNewline; Write-Host $t }
    function Step($t) { Write-Host ""; Write-Host ">> $t" -ForegroundColor White }
    function Pausa    { Write-Host ""; Read-Host "   ... ENTER para continuar" | Out-Null }

    function Pergunta($texto, $padrao) {
        if ($padrao) { $r = Read-Host "$texto [$padrao]" } else { $r = Read-Host $texto }
        if ([string]::IsNullOrWhiteSpace($r)) { return $padrao }
        return $r.Trim()
    }
    function Confirma($texto, $padrao = "s") {
        $r = Pergunta "$texto (s/n)" $padrao
        return ($r -match '^[sSyY]')
    }

    # ========================================================
    #  0. Abertura
    # ========================================================
    Clear-Host
    Write-Host ""
    Write-Host "   ____   _____   ____   _____   ____   ____    ___ "
    Write-Host "  / ___| | ____| |  _ \ | ____| | __ ) |  _ \  / _ \"
    Write-Host " | |     |  _|   | |_) ||  _|   |  _ \ | |_) || | | |"
    Write-Host " | |___  | |___  |  _ < | |___  | |_) ||  _ < | |_| |"
    Write-Host "  \____| |_____| |_| \_\|_____| |____/ |_| \_\ \___/ "
    Write-Host ""
    Write-Host "  Seu sistema pessoal, tocado pela IA que voce ja tem." -ForegroundColor White
    Write-Host "  versao $versao - cesarcampos.com.br/cerebro" -ForegroundColor DarkGray

    Tit "O QUE ISSO AQUI E"
    Write-Host @"
  Voce ja paga por uma IA de terminal (Claude Code, Codex ou
  Gemini CLI). Ela sabe ler e escrever arquivos no SEU computador.

  Falta so uma coisa: um LUGAR organizado para ela trabalhar.

  E isso que este instalador cria. Uma pasta com:

    INBOX/         voce joga tudo aqui, sem pensar. Audio, print,
                   ideia solta, print de conversa. E so despejar.
    10-Memoria/    o que voce quer que ele lembre para sempre
    20-Tarefas/    tarefas, backlog e lembretes
    30-Projetos/   uma pasta por frente sua
    90-Sistema/    log do que foi feito, backups e scripts

  Mais os arquivos de instrucao (CLAUDE.md, AGENTS.md, GEMINI.md)
  que ensinam a IA a se comportar como SEU assistente pessoal -
  com o nome que voce escolher e do jeito que voce gosta.

  Depois disso o seu dia vira isso:

    voce:  "processa meu inbox"
    ele:   le tudo o que voce jogou la, classifica, arquiva no
           lugar certo e te devolve o que precisa de decisao

    voce:  "o que temos para hoje?"
    ele:   abre suas tarefas, seus lembretes e seus projetos

  Tudo em arquivos .md de texto puro, na SUA maquina.
  Sem assinatura nova. Sem banco de dados. Sem nuvem de ninguem.
"@
    if ($DryRun) { Warn "MODO SIMULACAO: nada sera escrito no disco." }
    Pausa

    # ========================================================
    #  1. Sistema
    # ========================================================
    Step "1/6  Reconhecendo sua maquina"
    Ok "Windows detectado - PowerShell $($PSVersionTable.PSVersion.Major)"
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Err "Preciso do PowerShell 5 ou mais novo."
        return
    }

    # ========================================================
    #  2. Qual IA
    # ========================================================
    Step "2/6  Procurando um agente de IA instalado"

    $achados = @()
    foreach ($c in @("claude", "codex", "gemini")) {
        $cmd = Get-Command $c -ErrorAction SilentlyContinue
        if ($cmd) {
            $achados += $c
            $nome = switch ($c) { "claude" {"Claude Code"} "codex" {"Codex CLI"} "gemini" {"Gemini CLI"} }
            Ok "$nome encontrado  ($($cmd.Source))"
        }
    }

    if ($achados.Count -eq 0) {
        Write-Host ""
        Warn "Nao encontrei nenhum agente de IA no seu terminal."
        Write-Host @"

  O Cerebro nao e uma IA - ele e a casa onde a SUA IA mora.
  Entao voce precisa de uma destas tres. Instale a que combina
  com a conta que voce JA paga e rode este instalador de novo:

  Claude Code  (Anthropic - conta Claude Pro ou Max)
     npm install -g @anthropic-ai/claude-code
     https://claude.com/claude-code

  Codex CLI    (OpenAI - conta ChatGPT Plus ou Pro)
     npm install -g @openai/codex
     https://developers.openai.com/codex/cli

  Gemini CLI   (Google - conta Google, tem faixa gratuita)
     npm install -g @google/gemini-cli
     https://github.com/google-gemini/gemini-cli

  Obs.: o Antigravity, do Google, e um editor - nao e o CLI.
  Quem voce quer no terminal e o "gemini" da lista acima.

  As tres precisam do Node.js instalado:  https://nodejs.org

"@
        return
    }

    if ($Cli) {
        $cliEscolhido = $Cli
    } elseif ($achados.Count -eq 1) {
        $cliEscolhido = $achados[0]
        Write-Host ""
        Ok "Vou usar o $cliEscolhido - e o unico que voce tem por aqui."
    } else {
        Write-Host ""
        Write-Host "  Voce tem mais de um. Qual deles vai tocar o seu Cerebro?"
        Write-Host ""
        for ($i = 0; $i -lt $achados.Count; $i++) {
            Write-Host "    $($i+1)) $($achados[$i])"
        }
        Write-Host ""
        $n = Pergunta "  Numero" "1"
        $idx = 0
        [int]::TryParse($n, [ref]$idx) | Out-Null
        if ($idx -lt 1 -or $idx -gt $achados.Count) { $idx = 1 }
        $cliEscolhido = $achados[$idx - 1]
        Ok "Escolhido: $cliEscolhido"
    }

    if ($achados -notcontains $cliEscolhido -and -not $Cli) { $cliEscolhido = $achados[0] }

    Write-Host ""
    Write-Host "  Os arquivos de instrucao serao criados para os TRES mesmo assim." -ForegroundColor DarkGray
    Write-Host "  Se um dia voce trocar de IA, o seu Cerebro continua funcionando."  -ForegroundColor DarkGray

    # ========================================================
    #  3. Onde fica a pasta
    # ========================================================
    Step "3/6  Escolhendo onde o seu Cerebro vai morar"

    if ($Dir) {
        $destino = $Dir
    } else {
        Write-Host @"

  Duas escolas, e as duas funcionam:

  A) Dentro de uma pasta que sincroniza na nuvem
     (OneDrive, Google Drive, Dropbox)
     Voce abre o mesmo Cerebro de outro computador e tem backup
     automatico. E o que eu recomendo. Tem um detalhe importante
     que eu vou te explicar daqui a pouco - nao pule aquela parte.

  B) Numa pasta comum do seu computador
     Mais simples e mais rapido, mas o backup fica por sua conta.

"@
        $perfil = $env:USERPROFILE
        $candidatos = @()
        foreach ($p in @("$perfil\OneDrive", "$perfil\Google Drive", "$perfil\GoogleDrive",
                         "$perfil\Meu Drive", "$perfil\Dropbox", "$perfil\Documents", "$perfil\Documentos")) {
            if (Test-Path $p) { $candidatos += $p }
        }
        Get-ChildItem -Path $perfil -Directory -Filter "OneDrive - *" -ErrorAction SilentlyContinue |
            ForEach-Object { $candidatos += $_.FullName }
        foreach ($letra in @("G:", "H:")) {
            if (Test-Path "$letra\Meu Drive")  { $candidatos += "$letra\Meu Drive" }
            if (Test-Path "$letra\My Drive")   { $candidatos += "$letra\My Drive" }
        }
        $candidatos = $candidatos | Select-Object -Unique

        $base = ""
        if ($candidatos.Count -gt 0) {
            Write-Host "  Achei estas pastas na sua maquina:"
            Write-Host ""
            for ($i = 0; $i -lt $candidatos.Count; $i++) { Write-Host "    $($i+1)) $($candidatos[$i])" }
            Write-Host "    $($candidatos.Count + 1)) Digitar outro caminho"
            Write-Host ""
            $n = Pergunta "  Numero" "1"
            $idx = 0
            [int]::TryParse($n, [ref]$idx) | Out-Null
            if ($idx -eq ($candidatos.Count + 1)) {
                $base = Pergunta "  Caminho completo da pasta" $perfil
            } elseif ($idx -ge 1 -and $idx -le $candidatos.Count) {
                $base = $candidatos[$idx - 1]
            } else {
                $base = $candidatos[0]
            }
        } else {
            Warn "Nao achei pasta de nuvem automaticamente."
            $base = Pergunta "  Caminho da pasta onde criar" $perfil
        }

        $nomePasta = Pergunta "  Nome da pasta do seu Cerebro" "Cerebro"
        $destino = Join-Path $base $nomePasta
    }

    Write-Host ""
    Write-Host "  Vou montar tudo em:"
    Write-Host "  $destino" -ForegroundColor Cyan

    if (Test-Path $destino) {
        Write-Host ""
        Warn "Essa pasta ja existe."
        if ((Test-Path (Join-Path $destino "CLAUDE.md")) -or (Test-Path (Join-Path $destino "AGENTS.md"))) {
            Warn "E parece ja ter um Cerebro dentro dela."
        }
        Write-Host "  Eu nunca sobrescrevo arquivo seu: o que ja existir fica como esta," -ForegroundColor DarkGray
        Write-Host "  e eu so acrescento o que estiver faltando." -ForegroundColor DarkGray
        Write-Host ""
        if (-not (Confirma "  Posso continuar assim" "s")) {
            Err "Ok, cancelado. Nada foi alterado."
            return
        }
    }

    # ========================================================
    #  4. Sincronizacao e backup
    # ========================================================
    Step "4/6  Sincronizacao e backup - leia isso com calma"

    $naNuvem = $destino -match "OneDrive|Google ?Drive|Meu Drive|My Drive|Dropbox|Insync|Nextcloud"

    if ($naNuvem) {
        Write-Host @"

  Sua pasta fica dentro de um servico de nuvem. Otimo - mas
  existe uma armadilha que quase ninguem conta, e ela ja fez
  gente perder trabalho.

  O problema, em portugues claro:

  Dentro do seu Cerebro vai existir uma pasta chamada .claude
  (repare no ponto na frente do nome). O ponto quer dizer
  "arquivo oculto" - o proprio sistema esconde ela de voce.

  E dentro dela que ficam os COMANDOS e as HABILIDADES do seu
  agente. E o cerebro do Cerebro, por assim dizer.

  So que varios programas de sincronizacao IGNORAM pastas
  ocultas - ou sincronizam mal e criam copias conflitantes.

  Traduzindo: seus arquivos de conteudo sobem para a nuvem,
  mas as instrucoes do seu agente podem NAO subir. No dia em
  que voce trocar de computador, o texto estara la e o agente
  estara burro. E voce nao vai entender o porque.

  Como eu resolvo isso para voce:

  Vou criar um script chamado backup-cerebro dentro de
  90-Sistema\scripts\. Ele compacta o que e oculto e joga o
  pacote em 90-Sistema\backups\, que e uma pasta visivel -
  e o que e visivel a nuvem leva.

  O que nao sincroniza sozinho passa a viajar de carona
  dentro do que sincroniza.

  O que fica com voce: rodar esse backup de vez em quando.
  Uma vez por semana ja resolve. E eu vou deixar isso escrito
  dentro do proprio Cerebro para o seu agente te lembrar disso
  quando voce mexer nas configuracoes.

"@
    } else {
        Write-Host @"

  Voce escolheu uma pasta local, fora de nuvem. Funciona
  perfeitamente - mas entao vale combinar uma coisa:

  Se essa maquina morrer hoje, esse Cerebro morre junto.

  Vou instalar mesmo assim um script backup-cerebro em
  90-Sistema\scripts\. Ele empacota tudo, inclusive a pasta
  oculta .claude (onde ficam os comandos do seu agente).

  Rode ele de tempos em tempos e guarde o pacote em algum
  lugar fora deste computador - pen drive, e-mail para voce
  mesmo, qualquer nuvem. E dois minutos que um dia salvam meses.

"@
    }
    Pausa

    # ========================================================
    #  5. Baixar e montar
    # ========================================================
    Step "5/6  Montando a estrutura"

    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("cerebro-" + [guid]::NewGuid().ToString("N").Substring(0,8))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null

    try {
        $url = "https://codeload.github.com/$repoUser/$repoName/zip/refs/heads/$repoBranch"
        $zip = Join-Path $tmp "cerebro.zip"
        Write-Host "  Baixando o modelo..."
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        } catch {}
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $tmp -Force
        $fonte = Join-Path $tmp "$repoName-$repoBranch\template"
        if (-not (Test-Path $fonte)) { Err "Pacote invalido: nao achei a pasta template."; return }
        Ok "Modelo baixado"

        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $destino | Out-Null }

        # copia SEM sobrescrever nada que ja exista
        Get-ChildItem -Path $fonte -Recurse -Force | ForEach-Object {
            $rel = $_.FullName.Substring($fonte.Length).TrimStart('\')
            $alvo = Join-Path $destino $rel
            if ($_.PSIsContainer) {
                if ($DryRun) { Write-Host "   [dry-run] pasta  $rel" -ForegroundColor DarkGray }
                else { New-Item -ItemType Directory -Force -Path $alvo | Out-Null }
            } else {
                if (Test-Path $alvo) {
                    Write-Host "   mantido (ja existia): $rel" -ForegroundColor DarkGray
                } elseif ($DryRun) {
                    Write-Host "   [dry-run] arquivo $rel" -ForegroundColor DarkGray
                } else {
                    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $alvo) | Out-Null
                    Copy-Item $_.FullName $alvo
                }
            }
        }

        $boot = Join-Path $tmp "$repoName-$repoBranch\BOOTSTRAP.md"
        if ((Test-Path $boot) -and -not $DryRun) { Copy-Item $boot (Join-Path $destino "BOOTSTRAP.md") -Force }

        if (-not $DryRun) {
            $marca = @(
                "# gerado pelo instalador do Cerebro - nao precisa editar a mao",
                "versao_instalador: `"$versao`"",
                "sistema: `"windows`"",
                "cli_escolhido: `"$cliEscolhido`"",
                "pasta_em_nuvem: $([int][bool]$naNuvem)",
                "instalado_em: `"$(Get-Date -Format 'yyyy-MM-dd')`""
            )
            $marca | Set-Content -Path (Join-Path $destino ".cerebro-install.yml") -Encoding UTF8
        }

        Ok "Estrutura criada em $destino"
    }
    finally {
        Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }

    # ========================================================
    #  6. O atalho "agente"
    # ========================================================
    Step "6/6  Criando o atalho"

    if ($NoShortcut) {
        Warn "Pulei o atalho (-NoShortcut)."
    } else {
        Write-Host @"

  Ultimo passo, e o mais gostoso: um atalho.

  Depois dele, de qualquer lugar do terminal voce digita

      agente

  e o seu assistente abre ja dentro da pasta certa,
  ja sabendo quem voce e.

"@
        if (Confirma "  Crio o atalho 'agente'" "s") {
            if ($DryRun) {
                Write-Host "   [dry-run] adicionaria o atalho em $PROFILE" -ForegroundColor DarkGray
            } else {
                $pastaPerfil = Split-Path -Parent $PROFILE
                if (-not (Test-Path $pastaPerfil)) { New-Item -ItemType Directory -Force -Path $pastaPerfil | Out-Null }
                if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Force -Path $PROFILE | Out-Null }

                # remove bloco anterior, se houver (instalacao idempotente)
                $conteudo = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
                if ($conteudo -and $conteudo -match "# >>> cerebro >>>") {
                    $limpo = [regex]::Replace($conteudo, "(?s)# >>> cerebro >>>.*?# <<< cerebro <<<\r?\n?", "")
                    Set-Content -Path $PROFILE -Value $limpo -Encoding UTF8
                }

                $bloco = @"
# >>> cerebro >>>
`$env:CEREBRO_DIR = "$destino"
function agente { Set-Location `$env:CEREBRO_DIR; & $cliEscolhido @args }
# <<< cerebro <<<
"@
                Add-Content -Path $PROFILE -Value $bloco -Encoding UTF8
                Ok "Atalho instalado em $PROFILE"
                Write-Host ""
                Write-Host "  Para valer nesta janela, rode:  . `$PROFILE" -ForegroundColor DarkGray
                Write-Host "  (ou simplesmente feche e abra o terminal)" -ForegroundColor DarkGray
                Write-Host ""
                Write-Host "  Se o Windows reclamar de 'script desabilitado', rode uma vez:" -ForegroundColor DarkGray
                Write-Host "  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" -ForegroundColor DarkGray
            }
        } else {
            Write-Host ""
            Write-Host "  Sem problema. Para trabalhar, entre na pasta e chame a IA:"
            Write-Host "     cd `"$destino`"; $cliEscolhido"
        }
    }

    # ========================================================
    #  Fim - passa o bastao para o agente
    # ========================================================
    Tit "PRONTO. E agora a parte boa."
    Write-Host @"
  A estrutura esta de pe. Mas ela ainda e generica - nao sabe
  quem voce e.

  Quem vai personalizar isso nao sou eu, este scriptzinho burro
  de terminal. E o seu proprio agente, conversando com voce.

  Ele vai te perguntar como quer ser chamado, que nome voce quer
  dar para ele, com que tom ele fala com voce e o que voce faz
  da vida. E com as suas respostas ele escreve os arquivos de
  instrucao dele mesmo, na sua frente.

  Leva uns 3 minutos e e a unica vez que voce faz isso.

"@

    if ($DryRun) {
        Write-Host "  [dry-run] Aqui eu abriria: $cliEscolhido dentro de $destino" -ForegroundColor DarkGray
        return
    }

    $promptInicial = "Leia o arquivo BOOTSTRAP.md nesta pasta e execute o que esta escrito nele, do inicio ao fim. Fale comigo em portugues do Brasil."

    if ((-not $NoLaunch) -and (Confirma "  Chamo o $cliEscolhido agora para fazer essa entrevista" "s")) {
        Set-Location $destino
        Write-Host ""
        Write-Host "  Passando o bastao para o $cliEscolhido..." -ForegroundColor Green
        Write-Host ""
        & $cliEscolhido $promptInicial
    } else {
        Write-Host @"

  Tudo bem. Quando quiser fazer a entrevista, e so rodar:

      cd "$destino"
      $cliEscolhido

  e pedir para ele: "leia o BOOTSTRAP.md e siga o que esta la"

"@
    }
}

Install-Cerebro
