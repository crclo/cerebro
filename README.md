# 🧠 Cérebro

**Seu sistema pessoal, tocado pela IA que você já tem.**

Se você já paga por **Claude Code**, **Codex CLI** ou **Gemini CLI**, você já tem
um assistente pessoal completo. Falta só um lugar organizado para ele trabalhar.

É isso que este instalador cria — em um comando, em 3 minutos.

Sem assinatura nova. Sem banco de dados. Sem nuvem de ninguém.
Só arquivos de texto, na sua máquina, que são seus.

---

## Instalação

**Linux e macOS**

```bash
curl -fsSL https://cesarcampos.com.br/cerebro | bash
```

**Windows** (PowerShell)

```powershell
irm https://cesarcampos.com.br/cerebro.ps1 | iex
```

<details>
<summary>Prefere o endereço direto do GitHub, sem passar pelo domínio?</summary>

```bash
# Linux e macOS
curl -fsSL https://raw.githubusercontent.com/crclo/cerebro/main/install.sh | bash
```
```powershell
# Windows
irm https://raw.githubusercontent.com/crclo/cerebro/main/install.ps1 | iex
```
</details>

### Prefere ler antes de rodar? Faça isso. Sempre.

```bash
curl -fsSL https://cesarcampos.com.br/cerebro -o instalar.sh
less instalar.sh          # leia com calma
bash instalar.sh
```

> São **menos de 500 linhas de bash**, comentadas em português. Vale os dois
> minutos de leitura — em qualquer script que peça para rodar na sua máquina.

Ou veja o que aconteceria, sem escrever nada no disco:

```bash
curl -fsSL https://cesarcampos.com.br/cerebro | bash -s -- --dry-run
```

---

## O que ele faz

1. **Reconhece** qual agente de IA você tem instalado — e se não tiver nenhum,
   te mostra qual instalar de acordo com a conta que você já paga.
2. **Pergunta onde** o seu Cérebro vai morar (Google Drive, OneDrive, Dropbox
   ou uma pasta local) — detectando as opções sozinho.
3. **Explica a armadilha da sincronização** e instala o script de backup que
   resolve ela. Essa parte quase ninguém conta. [Entenda aqui](#a-armadilha-da-nuvem).
4. **Monta a estrutura** de pastas e as rotinas do dia a dia.
5. **Cria o atalho `agente`** — você digita isso de qualquer lugar e a sua IA
   abre já dentro da pasta certa.
6. **Passa o bastão para o seu agente**, que te entrevista e escreve as próprias
   instruções com o nome que você der a ele.

O passo 6 é o truque: **o script não te entrevista, ele instala o entrevistador.**

---

## O que fica na sua máquina

```
Cerebro/
├── CLAUDE.md      ┐
├── AGENTS.md      ├─ os três idênticos: funciona em qualquer uma das três IAs
├── GEMINI.md      ┘
├── config.yml
├── INBOX/            você joga tudo aqui, sem organizar
├── 10-Memoria/       o que ele deve lembrar para sempre
├── 20-Tarefas/       tarefas · backlog · lembretes
├── 30-Projetos/      uma pasta por frente de trabalho
├── 90-Sistema/
│   ├── rotinas/      o que o agente sabe fazer (texto puro)
│   ├── scripts/      backup-cerebro.sh e .ps1
│   ├── backups/
│   └── log/          o registro do que foi feito
└── .claude/          comandos e habilidades do Claude Code
```

### Por que três arquivos de instrução iguais

O Claude Code lê `CLAUDE.md`. O Codex lê `AGENTS.md`. O Gemini CLI lê `GEMINI.md`.

Mantendo os três idênticos, **o seu Cérebro não fica preso a nenhuma das três
empresas**. Trocou de IA? A sua vida organizada continua exatamente onde estava.

E as rotinas ficam em `90-Sistema/rotinas/`, em markdown puro — qualquer agente
consegue ler e executar, hoje ou daqui a cinco anos.

---

## Como se usa no dia a dia

```
você:  processa meu inbox
ele:   lê tudo o que você jogou lá, classifica, arquiva no lugar certo
       e te devolve só o que precisa de decisão sua

você:  /hoje
ele:   tarefas de hoje, o que está atrasado e os lembretes

você:  guarda que a senha do portão da academia é o aniversário da minha filha
ele:   guardado em 10-Memoria/

você:  o que eu tinha combinado com o Paulo?
ele:   busca em tudo e te responde com o arquivo onde está
```

Sem comando mágico. Você fala como falaria com um assistente humano.

---

## A armadilha da nuvem

Dentro do seu Cérebro existe uma pasta chamada `.claude` — com um **ponto** na
frente. Isso quer dizer que ela é **oculta**: o sistema esconde ela de você.

E é ali que ficam os comandos e as habilidades do seu agente.

**Vários serviços de sincronização ignoram pastas ocultas.** Resultado: seus
textos sobem para a nuvem, mas as instruções do seu agente não. No dia em que
você trocar de computador, o conteúdo está lá e o agente está burro — e você não
entende o porquê.

O instalador resolve isso com um script que **empacota o que é oculto e coloca o
pacote numa pasta visível**. O que não sincroniza sozinho passa a viajar de
carona dentro do que sincroniza.

```bash
bash 90-Sistema/scripts/backup-cerebro.sh     # Linux/macOS
```
```powershell
powershell -File 90-Sistema\scripts\backup-cerebro.ps1   # Windows
```

Ou simplesmente peça: **"roda o backup"**. Uma vez por semana resolve.

---

## Opções do instalador

| Opção | O que faz |
|---|---|
| `--dry-run` | Mostra tudo o que faria, sem escrever nada |
| `--dir=CAMINHO` | Já diz onde criar, pulando a pergunta |
| `--cli=NOME` | `claude`, `codex` ou `gemini` |
| `--no-shortcut` | Não cria o atalho `agente` |

```bash
curl -fsSL https://cesarcampos.com.br/cerebro | bash -s -- --dir=~/Cerebro --cli=claude
```

No Windows, baixe o `.ps1` e chame `Install-Cerebro -DryRun`.

---

## Como desinstalar

Não tem desinstalador, porque não tem nada escondido:

1. Apague a pasta do seu Cérebro.
2. Apague o bloco entre `# >>> cerebro >>>` e `# <<< cerebro <<<` do seu
   `~/.bashrc`, `~/.zshrc` ou `$PROFILE`.

Pronto. Nada de registro do Windows, nada de serviço rodando, nada de conta.

---

## Perguntas rápidas

**Isso é uma IA?**
Não. É a casa onde a sua IA mora. Você precisa ter Claude Code, Codex CLI ou
Gemini CLI instalado.

**Tem custo?**
Não. Você já paga a sua IA — este projeto é gratuito e de código aberto.

**Meus dados vão para algum lugar?**
Não. Tudo fica na sua máquina, em arquivos `.md`. O instalador só baixa este
repositório e cria pastas.

**O Antigravity serve?**
O Antigravity é o editor do Google. O que você quer no terminal é o **Gemini
CLI** (`npm install -g @google/gemini-cli`).

**Funciona com Obsidian?**
Sim, e muito bem. São arquivos markdown — abra a pasta como um cofre.

---

## Licença

MIT. Use, modifique, ensine, venda. Só não diga que foi você quem fez. 🙂

Feito por [Cesar Campos](https://cesarcampos.com.br) ·
[canal no YouTube](https://youtube.com/@cesarcamposbr)
