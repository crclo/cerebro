#!/usr/bin/env bash
# ============================================================
#  Cerebro - instalador para Linux e macOS
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

set -euo pipefail

REPO_USER="crclo"
REPO_NAME="cerebro"
REPO_BRANCH="main"
VERSION="1.0.0"

DRY_RUN=0
ARG_DIR=""
ARG_CLI=""
NO_SHORTCUT=0
NO_LAUNCH=0

# ------------------------------------------------------------
# Cores (desligadas quando nao ha terminal)
# ------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; R=$'\033[0m'
  AZ=$'\033[38;5;39m'; VD=$'\033[38;5;42m'; AM=$'\033[38;5;214m'; VM=$'\033[38;5;203m'
else
  B=""; DIM=""; R=""; AZ=""; VD=""; AM=""; VM=""
fi

say()  { printf '%s\n' "$*"; }
tit()  { printf '\n%s%s%s\n' "$B$AZ" "$*" "$R"; }
ok()   { printf '%s  OK  %s %s\n' "$VD" "$R" "$*"; }
warn() { printf '%s  !   %s %s\n' "$AM" "$R" "$*"; }
err()  { printf '%s  X   %s %s\n' "$VM" "$R" "$*" >&2; }
step() { printf '\n%s>> %s%s\n' "$B" "$*" "$R"; }

die() { err "$*"; exit 1; }

# ------------------------------------------------------------
# Leitura do teclado mesmo rodando via "curl | bash"
# (nesse caso o stdin e o proprio script, entao usamos /dev/tty)
# ------------------------------------------------------------
TTY_OK=0
if [ -r /dev/tty ]; then TTY_OK=1; fi

ask() {  # ask "pergunta" "padrao" -> ecoa resposta
  local prompt="$1" padrao="${2:-}" resposta=""
  if [ "$TTY_OK" -eq 0 ]; then printf '%s' "$padrao"; return 0; fi
  if [ -n "$padrao" ]; then
    printf '%s%s%s [%s]: ' "$B" "$prompt" "$R" "$padrao" > /dev/tty
  else
    printf '%s%s%s: ' "$B" "$prompt" "$R" > /dev/tty
  fi
  IFS= read -r resposta < /dev/tty || true
  [ -z "$resposta" ] && resposta="$padrao"
  printf '%s' "$resposta"
}

confirma() {  # confirma "pergunta" "s|n"  -> retorna 0 para sim
  local padrao="${2:-s}" r
  r="$(ask "$1 (s/n)" "$padrao")"
  case "$r" in [sSyY]*) return 0 ;; *) return 1 ;; esac
}

pausa() {
  [ "$TTY_OK" -eq 0 ] && return 0
  printf '\n%s   ... ENTER para continuar%s' "$DIM" "$R" > /dev/tty
  IFS= read -r _ < /dev/tty || true
  printf '\n' > /dev/tty
}

# ------------------------------------------------------------
# Argumentos
# ------------------------------------------------------------
mostra_ajuda() {
  cat <<AJUDA
Cerebro ${VERSION} - instalador (Linux/macOS)

  curl -fsSL https://cesarcampos.com.br/cerebro | bash
  curl -fsSL https://cesarcampos.com.br/cerebro | bash -s -- [opcoes]

Opcoes:
  --dry-run        Mostra tudo o que faria, sem escrever nada
  --dir=CAMINHO    Pasta onde criar o Cerebro (pula a pergunta)
  --cli=NOME       claude | codex | gemini (pula a pergunta)
  --no-shortcut    Nao cria o atalho "agente" no seu shell
  -h, --help       Esta ajuda
AJUDA
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --dir=*) ARG_DIR="${1#*=}" ;;
    --cli=*) ARG_CLI="${1#*=}" ;;
    --no-shortcut) NO_SHORTCUT=1 ;;
    --no-launch) NO_LAUNCH=1 ;;
    -h|--help) mostra_ajuda; exit 0 ;;
    *) warn "Opcao ignorada: $1" ;;
  esac
  shift
done

run() {  # executa, ou so descreve quando --dry-run
  if [ "$DRY_RUN" -eq 1 ]; then printf '%s   [dry-run] %s%s\n' "$DIM" "$*" "$R"; else "$@"; fi
}

# ============================================================
#  0. Abertura
# ============================================================
clear 2>/dev/null || true
cat <<'BANNER'

   ____   _____   ____   _____   ____   ____    ___
  / ___| | ____| |  _ \ | ____| | __ ) |  _ \  / _ \
 | |     |  _|   | |_) ||  _|   |  _ \ | |_) || | | |
 | |___  | |___  |  _ < | |___  | |_) ||  _ < | |_| |
  \____| |_____| |_| \_\|_____| |____/ |_| \_\ \___/

BANNER
say "  ${B}Seu sistema pessoal, tocado pela IA que voce ja tem.${R}"
say "  ${DIM}versao ${VERSION} - cesarcampos.com.br/cerebro${R}"

tit "O QUE ISSO AQUI E"
cat <<TEXTO
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

TEXTO
[ "$DRY_RUN" -eq 1 ] && warn "MODO SIMULACAO: nada sera escrito no disco."
pausa

# ============================================================
#  1. Sistema
# ============================================================
step "1/6  Reconhecendo sua maquina"

SO="desconhecido"
case "$(uname -s)" in
  Darwin) SO="macos" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then SO="wsl"; else SO="linux"; fi ;;
  *) SO="outro" ;;
esac

case "$SO" in
  macos) ok "macOS detectado" ;;
  linux) ok "Linux detectado" ;;
  wsl)   ok "Windows (WSL) detectado" ;;
  *)     warn "Sistema nao reconhecido - vou seguir no modo Linux" ;;
esac

for dep in curl tar; do
  command -v "$dep" >/dev/null 2>&1 || die "Preciso do comando '$dep' e ele nao esta instalado."
done

# ============================================================
#  2. Qual IA
# ============================================================
step "2/6  Procurando um agente de IA instalado"

TEM_CLAUDE=0; TEM_CODEX=0; TEM_GEMINI=0
command -v claude >/dev/null 2>&1 && TEM_CLAUDE=1
command -v codex  >/dev/null 2>&1 && TEM_CODEX=1
command -v gemini >/dev/null 2>&1 && TEM_GEMINI=1

[ "$TEM_CLAUDE" -eq 1 ] && ok "Claude Code   encontrado  ($(command -v claude))"
[ "$TEM_CODEX"  -eq 1 ] && ok "Codex CLI     encontrado  ($(command -v codex))"
[ "$TEM_GEMINI" -eq 1 ] && ok "Gemini CLI    encontrado  ($(command -v gemini))"

TOTAL=$((TEM_CLAUDE + TEM_CODEX + TEM_GEMINI))

if [ "$TOTAL" -eq 0 ]; then
  cat <<TEXTO

  ${AM}Nao encontrei nenhum agente de IA no seu terminal.${R}

  O Cerebro nao e uma IA - ele e a casa onde a SUA IA mora.
  Entao voce precisa de uma destas tres. Instale a que combina
  com a conta que voce JA paga e rode este instalador de novo:

  ${B}Claude Code${R}  (Anthropic - conta Claude Pro ou Max)
     npm install -g @anthropic-ai/claude-code
     https://claude.com/claude-code

  ${B}Codex CLI${R}    (OpenAI - conta ChatGPT Plus ou Pro)
     npm install -g @openai/codex
     https://developers.openai.com/codex/cli

  ${B}Gemini CLI${R}   (Google - conta Google, tem faixa gratuita)
     npm install -g @google/gemini-cli
     https://github.com/google-gemini/gemini-cli

  ${DIM}Obs.: o Antigravity, do Google, e um editor - nao e o CLI.
  Quem voce quer no terminal e o "gemini" da lista acima.${R}

  As tres precisam do Node.js instalado:  https://nodejs.org

TEXTO
  exit 1
fi

CLI=""
if [ -n "$ARG_CLI" ]; then
  CLI="$ARG_CLI"
elif [ "$TOTAL" -eq 1 ]; then
  [ "$TEM_CLAUDE" -eq 1 ] && CLI="claude"
  [ "$TEM_CODEX"  -eq 1 ] && CLI="codex"
  [ "$TEM_GEMINI" -eq 1 ] && CLI="gemini"
  say ""
  ok "Vou usar o ${B}${CLI}${R} - e o unico que voce tem por aqui."
else
  say ""
  say "  Voce tem mais de um. Qual deles vai tocar o seu Cerebro?"
  say ""
  n=0
  OP1=""; OP2=""; OP3=""
  [ "$TEM_CLAUDE" -eq 1 ] && { n=$((n+1)); eval "OP$n=claude"; say "    $n) Claude Code"; }
  [ "$TEM_CODEX"  -eq 1 ] && { n=$((n+1)); eval "OP$n=codex";  say "    $n) Codex CLI"; }
  [ "$TEM_GEMINI" -eq 1 ] && { n=$((n+1)); eval "OP$n=gemini"; say "    $n) Gemini CLI"; }
  say ""
  esc="$(ask "  Numero" "1")"
  case "$esc" in 1) CLI="$OP1" ;; 2) CLI="$OP2" ;; 3) CLI="$OP3" ;; *) CLI="$OP1" ;; esac
  ok "Escolhido: ${B}${CLI}${R}"
fi

case "$CLI" in
  claude|codex|gemini) : ;;
  *) die "CLI invalido: '$CLI' (use claude, codex ou gemini)" ;;
esac

say ""
say "  ${DIM}Os arquivos de instrucao serao criados para os TRES mesmo assim.${R}"
say "  ${DIM}Se um dia voce trocar de IA, o seu Cerebro continua funcionando.${R}"

# ============================================================
#  3. Onde fica a pasta
# ============================================================
step "3/6  Escolhendo onde o seu Cerebro vai morar"

# Detecta pastas de sincronizacao na nuvem
CANDIDATOS=()
adiciona() { [ -d "$1" ] && CANDIDATOS+=("$1"); }

if [ "$SO" = "macos" ]; then
  for d in "$HOME"/Library/CloudStorage/GoogleDrive-*/Meu\ Drive "$HOME"/Library/CloudStorage/GoogleDrive-*/My\ Drive; do adiciona "$d"; done
  for d in "$HOME"/Library/CloudStorage/OneDrive*; do adiciona "$d"; done
  adiciona "$HOME/Library/Mobile Documents/com~apple~CloudDocs"
fi
for d in "$HOME"/Insync/*/Google\ Drive; do adiciona "$d"; done
adiciona "$HOME/Google Drive"
adiciona "$HOME/GoogleDrive"
adiciona "$HOME/OneDrive"
adiciona "$HOME/Dropbox"
if [ "$SO" = "wsl" ]; then
  for d in /mnt/c/Users/*/OneDrive /mnt/c/Users/*/"Google Drive"; do adiciona "$d"; done
fi
adiciona "$HOME/Documentos"
adiciona "$HOME/Documents"

BASE=""
if [ -n "$ARG_DIR" ]; then
  DESTINO="${ARG_DIR/#\~/$HOME}"
else
  cat <<TEXTO

  Duas escolas, e as duas funcionam:

  ${B}A) Dentro de uma pasta que sincroniza na nuvem${R}
     (Google Drive, OneDrive, Dropbox, iCloud)
     Voce abre o mesmo Cerebro de outro computador e tem backup
     automatico. E o que eu recomendo. Tem um detalhe importante
     que eu vou te explicar daqui a pouco - nao pule aquela parte.

  ${B}B) Numa pasta comum do seu computador${R}
     Mais simples e mais rapido, mas o backup fica por sua conta.

TEXTO
  if [ ${#CANDIDATOS[@]} -gt 0 ]; then
    say "  Achei estas pastas de nuvem na sua maquina:"
    say ""
    i=0
    for c in "${CANDIDATOS[@]}"; do i=$((i+1)); say "    $i) $c"; done
    i=$((i+1)); say "    $i) Digitar outro caminho"
    say ""
    esc="$(ask "  Numero" "1")"
    if [ "$esc" = "$i" ]; then
      BASE="$(ask "  Caminho completo da pasta" "$HOME")"
    else
      idx=1
      for c in "${CANDIDATOS[@]}"; do
        [ "$idx" = "$esc" ] && BASE="$c"
        idx=$((idx+1))
      done
      [ -z "$BASE" ] && BASE="${CANDIDATOS[0]}"
    fi
  else
    warn "Nao achei pasta de nuvem automaticamente."
    BASE="$(ask "  Caminho da pasta onde criar" "$HOME")"
  fi
  BASE="${BASE/#\~/$HOME}"
  NOME="$(ask "  Nome da pasta do seu Cerebro" "Cerebro")"
  DESTINO="$BASE/$NOME"
fi

say ""
say "  Vou montar tudo em:"
say "  ${B}${AZ}${DESTINO}${R}"

JA_EXISTE=0
if [ -e "$DESTINO" ]; then
  JA_EXISTE=1
  say ""
  warn "Essa pasta ja existe."
  if [ -f "$DESTINO/CLAUDE.md" ] || [ -f "$DESTINO/AGENTS.md" ]; then
    warn "E parece ja ter um Cerebro dentro dela."
  fi
  say "  ${DIM}Eu nunca sobrescrevo arquivo seu: o que ja existir fica como esta,${R}"
  say "  ${DIM}e eu so acrescento o que estiver faltando.${R}"
  say ""
  confirma "  Posso continuar assim" "s" || die "Ok, cancelado. Nada foi alterado."
fi

# ============================================================
#  4. A conversa sobre nuvem e backup
# ============================================================
step "4/6  Sincronizacao e backup - leia isso com calma"

NA_NUVEM=0
case "$DESTINO" in
  *[Gg]oogle*[Dd]rive*|*GoogleDrive*|*OneDrive*|*Dropbox*|*Insync*|*CloudDocs*|*[Nn]extcloud*) NA_NUVEM=1 ;;
esac

if [ "$NA_NUVEM" -eq 1 ]; then
  cat <<TEXTO

  Sua pasta fica dentro de um servico de nuvem. Otimo - mas
  existe uma armadilha que quase ninguem conta, e ela ja fez
  gente perder trabalho.

  ${B}O problema, em portugues claro:${R}

  Dentro do seu Cerebro vai existir uma pasta chamada ${B}.claude${R}
  (repare no ponto na frente do nome). O ponto quer dizer
  "arquivo oculto" - o proprio sistema esconde ela de voce.

  E dentro dela que ficam os COMANDOS e as HABILIDADES do seu
  agente. E o cerebro do Cerebro, por assim dizer.

  ${AM}So que varios programas de sincronizacao IGNORAM pastas${R}
  ${AM}ocultas - ou sincronizam mal e criam copias conflitantes.${R}

  Traduzindo: ${B}seus arquivos de conteudo sobem para a nuvem,${R}
  ${B}mas as instrucoes do seu agente podem NAO subir.${R} No dia em
  que voce trocar de computador, o texto estara la e o agente
  estara burro. E voce nao vai entender o porque.

  ${B}Como eu resolvo isso para voce:${R}

  Vou criar um script chamado ${B}backup-cerebro${R} dentro de
  90-Sistema/scripts/. Ele compacta o que e oculto e joga o
  pacote em 90-Sistema/backups/, que e uma pasta ${B}visivel${R} -
  e o que e visivel a nuvem leva.

  O que nao sincroniza sozinho passa a viajar de carona
  dentro do que sincroniza.

  ${B}O que fica com voce:${R} rodar esse backup de vez em quando.
  Uma vez por semana ja resolve. E eu vou deixar isso escrito
  dentro do proprio Cerebro para o seu agente te lembrar disso
  quando voce mexer nas configuracoes.

TEXTO
else
  cat <<TEXTO

  Voce escolheu uma pasta local, fora de nuvem. Funciona
  perfeitamente - mas entao vale combinar uma coisa:

  ${AM}Se essa maquina morrer hoje, esse Cerebro morre junto.${R}

  Vou instalar mesmo assim um script ${B}backup-cerebro${R} em
  90-Sistema/scripts/. Ele empacota tudo, inclusive a pasta
  oculta .claude (onde ficam os comandos do seu agente).

  Rode ele de tempos em tempos e guarde o pacote em algum
  lugar fora deste computador - pen drive, e-mail para voce
  mesmo, qualquer nuvem. E dois minutos que um dia salvam meses.

TEXTO
fi
pausa

# ============================================================
#  5. Baixar e montar
# ============================================================
step "5/6  Montando a estrutura"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

URL="https://codeload.github.com/${REPO_USER}/${REPO_NAME}/tar.gz/refs/heads/${REPO_BRANCH}"
say "  Baixando o modelo..."
if ! curl -fsSL "$URL" -o "$TMP/cerebro.tar.gz"; then
  die "Nao consegui baixar o modelo de $URL - verifique sua internet."
fi
tar -xzf "$TMP/cerebro.tar.gz" -C "$TMP" || die "Download veio corrompido. Tente de novo."
FONTE="$TMP/${REPO_NAME}-${REPO_BRANCH}/template"
[ -d "$FONTE" ] || die "Pacote invalido: nao achei a pasta template."
ok "Modelo baixado"

run mkdir -p "$DESTINO"

copia() {  # copia SEM sobrescrever nada que ja exista
  local de="$1" para="$2" rel
  ( cd "$de" && find . -type d -print0 ) | while IFS= read -r -d '' rel; do
    run mkdir -p "$para/${rel#./}"
  done
  ( cd "$de" && find . -type f -print0 ) | while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    if [ -e "$para/$rel" ]; then
      printf '%s   mantido (ja existia): %s%s\n' "$DIM" "$rel" "$R"
    else
      run cp "$de/$rel" "$para/$rel"
    fi
  done
}
copia "$FONTE" "$DESTINO"

# BOOTSTRAP.md fica na raiz: e o roteiro da entrevista
BOOT="$TMP/${REPO_NAME}-${REPO_BRANCH}/BOOTSTRAP.md"
[ -f "$BOOT" ] && run cp "$BOOT" "$DESTINO/BOOTSTRAP.md"

# Marca de que a pasta esta em nuvem (o agente le isso na entrevista)
if [ "$DRY_RUN" -eq 0 ]; then
  {
    echo "# gerado pelo instalador do Cerebro - nao precisa editar a mao"
    echo "versao_instalador: \"${VERSION}\""
    echo "sistema: \"${SO}\""
    echo "cli_escolhido: \"${CLI}\""
    echo "pasta_em_nuvem: ${NA_NUVEM}"
    echo "instalado_em: \"$(date +%Y-%m-%d)\""
  } > "$DESTINO/.cerebro-install.yml"
fi

ok "Estrutura criada em $DESTINO"

# Deixa os scripts de backup executaveis
[ -f "$DESTINO/90-Sistema/scripts/backup-cerebro.sh" ] && run chmod +x "$DESTINO/90-Sistema/scripts/backup-cerebro.sh"

# ============================================================
#  6. O atalho "agente"
# ============================================================
step "6/6  Criando o atalho"

if [ "$NO_SHORTCUT" -eq 1 ]; then
  warn "Pulei o atalho (--no-shortcut)."
else
  cat <<TEXTO

  Ultimo passo, e o mais gostoso: um atalho.

  Depois dele, de qualquer lugar do terminal voce digita

      ${B}${VD}agente${R}

  e o seu assistente abre ja dentro da pasta certa,
  ja sabendo quem voce e.

TEXTO
  if confirma "  Crio o atalho 'agente'" "s"; then
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
      [ -f "$rc" ] || continue
      if [ "$DRY_RUN" -eq 1 ]; then
        printf '%s   [dry-run] adicionaria o atalho em %s%s\n' "$DIM" "$rc" "$R"
        continue
      fi
      # remove bloco anterior, se houver (instalacao idempotente)
      if grep -q '# >>> cerebro >>>' "$rc" 2>/dev/null; then
        sed -i.cerebro-bak '/# >>> cerebro >>>/,/# <<< cerebro <<</d' "$rc"
        rm -f "$rc.cerebro-bak"
      fi
      cat >> "$rc" <<BLOCO
# >>> cerebro >>>
export CEREBRO_DIR="${DESTINO}"
agente() { cd "\$CEREBRO_DIR" || return 1; command ${CLI} "\$@"; }
# <<< cerebro <<<
BLOCO
      ok "Atalho instalado em $rc"
    done
    say ""
    say "  ${DIM}Para valer nesta janela do terminal, rode:  source ~/.bashrc${R}"
    say "  ${DIM}(ou simplesmente feche e abra o terminal)${R}"
  else
    say ""
    say "  Sem problema. Para trabalhar, entre na pasta e chame a IA:"
    say "     ${B}cd \"$DESTINO\" && $CLI${R}"
  fi
fi

# ============================================================
#  Fim - passa o bastao para o agente
# ============================================================
PROMPT_INICIAL="Leia o arquivo BOOTSTRAP.md nesta pasta e execute o que esta escrito nele, do inicio ao fim. Fale comigo em portugues do Brasil."

tit "PRONTO. E agora a parte boa."
cat <<TEXTO
  A estrutura esta de pe. Mas ela ainda e generica - nao sabe
  quem voce e.

  Quem vai personalizar isso nao sou eu, este scriptzinho burro
  de terminal. E o seu proprio agente, conversando com voce.

  Ele vai te perguntar como quer ser chamado, que nome voce quer
  dar para ele, com que tom ele fala com voce e o que voce faz
  da vida. E com as suas respostas ele escreve os arquivos de
  instrucao dele mesmo, na sua frente.

  ${DIM}Leva uns 3 minutos e e a unica vez que voce faz isso.${R}

TEXTO

if [ "$DRY_RUN" -eq 1 ]; then
  say "  ${DIM}[dry-run] Aqui eu abriria: $CLI dentro de $DESTINO${R}"
  say ""
  exit 0
fi

if [ "$NO_LAUNCH" -eq 0 ] && confirma "  Chamo o ${CLI} agora para fazer essa entrevista" "s"; then
  cd "$DESTINO"
  say ""
  say "  ${VD}Passando o bastao para o ${CLI}...${R}"
  say ""
  exec "$CLI" "$PROMPT_INICIAL"
else
  cat <<TEXTO

  Tudo bem. Quando quiser fazer a entrevista, e so rodar:

      ${B}cd "$DESTINO"${R}
      ${B}${CLI}${R}

  e pedir para ele: ${B}"leia o BOOTSTRAP.md e siga o que esta la"${R}

TEXTO
fi
