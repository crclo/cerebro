---
id: 0000-00-00-0000-backup-e-sincronizacao
titulo: Backup e sincronização
tipo: sistema
tags: [backup, sistema]
---

# 💾 Backup e sincronização — leia uma vez, lembre para sempre

## O problema, sem termo técnico

Dentro do seu Cérebro existe uma pasta chamada **`.claude`**.

Repare no **ponto** na frente do nome. Nos computadores, o ponto quer dizer
*"arquivo oculto"* — o sistema esconde ela de você no explorador de arquivos.
Você provavelmente nunca vai vê-la, mas ela está aí.

**E ela é a parte mais importante daqui.** É onde moram os comandos e as
habilidades do seu agente. É o que faz dele *o seu* assistente, e não um
assistente genérico igual ao de qualquer um.

O problema: **vários programas de sincronização ignoram pastas ocultas** — ou
sincronizam mal e criam cópias conflitantes.

Traduzindo o risco em uma frase:

> Os seus textos sobem para a nuvem, mas as instruções do seu agente podem não
> subir. No dia em que você trocar de computador, o conteúdo estará lá e o
> agente estará burro. E você não vai entender o porquê.

## A solução

Existe um script que **empacota o que é oculto e coloca o pacote numa pasta
visível** — e o que é visível a nuvem leva.

O que não sincroniza sozinho passa a viajar de carona dentro do que sincroniza.

### Como rodar

**Linux ou Mac** — dentro da pasta do seu Cérebro:

```bash
bash 90-Sistema/scripts/backup-cerebro.sh
```

**Windows** — dentro da pasta do seu Cérebro:

```powershell
powershell -ExecutionPolicy Bypass -File 90-Sistema\scripts\backup-cerebro.ps1
```

Ou, mais fácil: peça ao seu agente — **"roda o backup"**.

O pacote sai em `90-Sistema/backups/config-AAAA-MM-DD.zip` (ou `.tar.gz`).

### Quando rodar

- **Uma vez por semana**, de rotina.
- **Sempre que mexer** em comandos, rotinas ou nas instruções do agente.
- **Antes de formatar** ou trocar de computador.

## Se o seu Cérebro NÃO está na nuvem

Então o backup é ainda mais importante — e ele não basta ficar aqui dentro.
Copie o pacote para fora deste computador: pen drive, e-mail para você mesmo,
qualquer nuvem. **Se esta máquina morrer hoje, o Cérebro morre junto.**

## Como restaurar

Descompacte o pacote por cima da pasta do Cérebro no computador novo. Os
arquivos ocultos voltam para o lugar e o seu agente volta a ser o seu agente.
