#!/usr/bin/env bash
# Empacota o que NÃO sincroniza sozinho com a nuvem.
# Rode de dentro da pasta do seu Cérebro:  bash 90-Sistema/scripts/backup-cerebro.sh
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$RAIZ"

DESTINO="90-Sistema/backups"
mkdir -p "$DESTINO"
CARIMBO="$(date +%Y-%m-%d)"
PACOTE="$DESTINO/config-${CARIMBO}.tar.gz"

ALVOS=()
for alvo in .claude .gemini .codex config.yml CLAUDE.md AGENTS.md GEMINI.md 90-Sistema/rotinas; do
  [ -e "$alvo" ] && ALVOS+=("$alvo")
done

if [ ${#ALVOS[@]} -eq 0 ]; then
  echo "Nada para empacotar. Você está na pasta certa?"
  exit 1
fi

tar -czf "$PACOTE" "${ALVOS[@]}"

echo ""
echo "  Backup pronto:"
echo "  $RAIZ/$PACOTE"
echo ""
echo "  Esse pacote está numa pasta VISÍVEL — então a sua nuvem leva ele junto."
echo "  Dentro dele vão as suas configurações e comandos, que ficam em pastas"
echo "  ocultas e que muitos serviços de sincronização ignoram."
echo ""
echo "  Refaça isso sempre que mexer nas instruções do seu agente."
echo "  Uma vez por semana já resolve."
echo ""
