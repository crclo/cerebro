#!/usr/bin/env bash
# ============================================================
#  Bateria de testes do instalador.
#
#  Roda tudo num HOME falso, em /tmp - nao encosta na sua casa,
#  no seu .bashrc nem no seu Cerebro de verdade.
#
#      bash testar.sh           # testa o install.sh local
#      bash testar.sh --remoto  # testa o que esta publicado no GitHub
# ============================================================
set -eo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALVO="bash $AQUI/install.sh"
if [ "${1:-}" = "--remoto" ]; then
  ALVO="curl -fsSL https://raw.githubusercontent.com/crclo/cerebro/main/install.sh | bash -s --"
  echo "Testando a versao PUBLICADA no GitHub."
else
  echo "Testando o install.sh desta pasta."
fi

SANDBOX="/tmp/cerebro-testes-$$"
mkdir -p "$SANDBOX"
trap 'rm -rf "$SANDBOX"' EXIT

PASSOU=0; FALHOU=0
res() { if [ "$1" = "ok" ]; then PASSOU=$((PASSOU+1)); echo "  PASSOU  $2"; else FALHOU=$((FALHOU+1)); echo "  FALHOU  $2"; fi; }

lar() {  # cria um HOME falso com pastas de nuvem
  local h="$SANDBOX/$1"; mkdir -p "$h/Google Drive" "$h/OneDrive"; : > "$h/.bashrc"; echo "$h"
}

echo ""
echo "== 1. Instalacao nao interativa =="
H="$(lar h1)"
if env HOME="$H" bash -c "$ALVO --dir='$H/Google Drive/Cerebro' --cli=claude --no-shortcut --no-launch" >"$SANDBOX/1.log" 2>&1
then res ok "instalou sem erro"; else res x "instalou sem erro (veja $SANDBOX/1.log)"; fi

for f in CLAUDE.md AGENTS.md GEMINI.md config.yml BOOTSTRAP.md \
         INBOX/LEIA-ME.md 20-Tarefas/tarefas.md \
         90-Sistema/rotinas/hoje.md 90-Sistema/scripts/backup-cerebro.sh \
         90-Sistema/BACKUP-E-SINCRONIZACAO.md \
         .claude/commands/hoje.md .claude/skills/inbox/SKILL.md .gemini/commands/hoje.toml; do
  if [ -f "$H/Google Drive/Cerebro/$f" ]; then res ok "criou $f"; else res x "criou $f"; fi
done

if grep -q "pasta_em_nuvem: 1" "$H/Google Drive/Cerebro/.cerebro-install.yml"
then res ok "reconheceu a pasta como nuvem"; else res x "reconheceu a pasta como nuvem"; fi

if grep -q "armadilha que quase ninguem conta" "$SANDBOX/1.log"
then res ok "avisou sobre a sincronizacao"; else res x "avisou sobre a sincronizacao"; fi

echo ""
echo "== 2. Backup empacota o que e oculto =="
( cd "$H/Google Drive/Cerebro" && bash 90-Sistema/scripts/backup-cerebro.sh >/dev/null 2>&1 )
PACOTE="$(ls "$H/Google Drive/Cerebro/90-Sistema/backups/"*.tar.gz 2>/dev/null | head -1)"
if [ -n "$PACOTE" ]; then res ok "gerou o pacote"; else res x "gerou o pacote"; fi
if [ -n "$PACOTE" ] && tar -tzf "$PACOTE" | grep -q "^.claude/"
then res ok "o pacote leva a pasta oculta .claude"; else res x "o pacote leva a pasta oculta .claude"; fi

echo ""
echo "== 3. Rodar de novo nao destroi nada =="
echo "MARCA DO USUARIO" >> "$H/Google Drive/Cerebro/CLAUDE.md"
env HOME="$H" bash -c "$ALVO --dir='$H/Google Drive/Cerebro' --cli=claude --no-shortcut --no-launch" >"$SANDBOX/3.log" 2>&1 || true
if tail -1 "$H/Google Drive/Cerebro/CLAUDE.md" | grep -q "MARCA DO USUARIO"
then res ok "preservou o arquivo editado a mao"; else res x "preservou o arquivo editado a mao"; fi
if grep -q "mantido (ja existia)" "$SANDBOX/3.log"
then res ok "avisou o que manteve"; else res x "avisou o que manteve"; fi

echo ""
echo "== 4. Simulacao nao escreve nada =="
H2="$(lar h2)"
env HOME="$H2" bash -c "$ALVO --dry-run --dir='$H2/NaoDeveExistir' --cli=claude" >/dev/null 2>&1 || true
if [ ! -e "$H2/NaoDeveExistir" ]; then res ok "--dry-run nao criou pasta"; else res x "--dry-run nao criou pasta"; fi

echo ""
echo "== 5. Sem nenhuma IA instalada =="
H3="$(lar h3)"
if env -i HOME="$H3" PATH="/usr/bin:/bin" bash -c "$ALVO --no-launch" >"$SANDBOX/5.log" 2>&1
then res x "deveria sair com erro"; else res ok "saiu com erro, como esperado"; fi
if grep -q "Nao encontrei nenhum agente" "$SANDBOX/5.log"
then res ok "explicou qual instalar"; else res x "explicou qual instalar"; fi

# O comando "script" tem sintaxe diferente no GNU (Linux) e no BSD (macOS).
# Descobrimos qual e o desta maquina para conseguir simular um terminal.
SABOR_SCRIPT="nenhum"
if command -v script >/dev/null 2>&1; then
  if script -qec true /dev/null >/dev/null 2>&1; then SABOR_SCRIPT="gnu"
  elif script -q /dev/null true  >/dev/null 2>&1; then SABOR_SCRIPT="bsd"
  fi
fi

com_tty() {  # com_tty "comando shell" arquivo_de_saida
  case "$SABOR_SCRIPT" in
    gnu) script -qec "$1" /dev/null > "$2" 2>&1 ;;
    bsd) script -q /dev/null /bin/sh -c "$1" > "$2" 2>&1 ;;
    *)   return 1 ;;
  esac
}

echo ""
echo "== 6. O atalho 'agente' =="
H5="$(lar h5)"
env HOME="$H5" bash -c "$ALVO --dir='$H5/Google Drive/Cerebro' --cli=claude --no-launch" >"$SANDBOX/6a.log" 2>&1 || true
if grep -q 'agente()' "$H5/.bashrc"
then res ok "criou a funcao no .bashrc"; else res x "criou a funcao no .bashrc"; fi
if grep -q "CEREBRO_DIR=\"$H5/Google Drive/Cerebro\"" "$H5/.bashrc"
then res ok "apontou para a pasta certa"; else res x "apontou para a pasta certa"; fi
env HOME="$H5" bash -c "$ALVO --dir='$H5/Google Drive/Cerebro' --cli=codex --no-launch" >"$SANDBOX/6b.log" 2>&1 || true
if [ "$(grep -c '>>> cerebro >>>' "$H5/.bashrc")" = "1" ]
then res ok "reinstalar nao duplicou o bloco"; else res x "reinstalar nao duplicou o bloco"; fi
if grep -q 'command codex' "$H5/.bashrc"
then res ok "reinstalar atualizou a IA do atalho"; else res x "reinstalar atualizou a IA do atalho"; fi
if ! ls -a "$H5" | grep -q 'cerebro-bak'
then res ok "nao deixou arquivo de sobra"; else res x "nao deixou arquivo de sobra"; fi

echo ""
echo "== 7. Fluxo interativo com terminal de verdade =="
# So roda quando existe um terminal real para herdar. Em CI nao existe, e o
# "script" nao repassa o que vem por pipe - o instalador le de /dev/tty.
if [ "$SABOR_SCRIPT" != "nenhum" ] && [ -t 0 ]; then
  H4="$(lar h4)"
  printf '\n1\n1\nCerebro\n\ns\nn\n' | com_tty "env HOME=$H4 bash -c \"$ALVO\"" "$SANDBOX/6.log" || true
  if [ -f "$H4/Google Drive/Cerebro/CLAUDE.md" ]
  then res ok "instalou respondendo as perguntas"; else res x "instalou respondendo as perguntas"; fi
  if grep -q "agente()" "$H4/.bashrc"
  then res ok "criou o atalho 'agente'"; else res x "criou o atalho 'agente'"; fi
  printf '\n1\n1\nCerebro\ns\n\ns\nn\n' | com_tty "env HOME=$H4 bash -c \"$ALVO --no-launch\"" "$SANDBOX/6b.log" || true
  if [ "$(grep -c '>>> cerebro >>>' "$H4/.bashrc")" = "1" ]
  then res ok "nao duplicou o atalho na segunda vez"; else res x "nao duplicou o atalho na segunda vez"; fi
  if ! ls -a "$H4" | grep -q 'cerebro-bak'
  then res ok "nao deixou arquivo de sobra"; else res x "nao deixou arquivo de sobra"; fi
else
  echo "  (pulado: precisa de um terminal de verdade - nao roda em CI)"
fi

echo ""
echo "============================================"
echo "  passou: $PASSOU    falhou: $FALHOU"
echo "============================================"
[ "$FALHOU" -eq 0 ]
