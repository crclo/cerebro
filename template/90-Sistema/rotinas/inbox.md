# Rotina: PROCESSAR O INBOX

Para **cada** item em `INBOX/` (ignore o `LEIA-ME.md`):

1. **Leia e entenda** o que é: ideia, tarefa, documento, anotação de reunião,
   material de estudo, comprovante, contato.
2. **Classifique** o destino:
   | O que é | Vai para |
   |---|---|
   | Coisa para lembrar | `10-Memoria/` |
   | Tarefa ou prazo | sugira em `20-Tarefas/` — **não escreva sem autorização** |
   | Assunto de um projeto | `30-Projetos/<projeto>/` |
   | Anotação de reunião | `60-Reunioes/` (crie se ele usa esse módulo) |
   | Não deu para entender | **deixe no INBOX** e pergunte |
3. **Crie a nota** com cabeçalho completo (`id`, `titulo`, `tipo`, `data`, `tags`).
4. **Mova** o original para o destino. Nunca apague nada.

Ao final, devolva:
- Quantos itens processados e para onde foram
- **O que precisa de decisão sua** (a parte mais importante)
- Tarefas **sugeridas**, para ele aprovar ou não
- Conexões que você percebeu com projetos que já existem

Registre a linha no log.
