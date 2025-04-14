[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/4nHL7_6-)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=18897163&assignment_repo_type=AssignmentRepo)
# CS 164: Programming Assignment 1

[PA1 Specification]: https://drive.google.com/open?id=1oYcJ5iv7Wt8oZNS1bEfswAklbMxDtwqB
[ChocoPy Specification]: https://drive.google.com/file/d/1mrgrUFHMdcqhBYzXHG24VcIiSrymR6wt

Note: Users running Windows should replace the colon (`:`) with a semicolon (`;`) in the classpath argument for all command listed below.

## Getting started

Run the following command to generate and compile your parser, and then run all the provided tests:

    mvn clean package

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=s --test --dir src/test/data/pa1/sample/

In the starter code, only one test should pass. Your objective is to build a parser that passes all the provided tests and meets the assignment specifications.

To manually observe the output of your parser when run on a given input ChocoPy program, run the following command (replace the last argument to change the input file):

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=s src/test/data/pa1/sample/expr_plus.py

You can check the output produced by the staff-provided reference implementation on the same input file, as follows:

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=r src/test/data/pa1/sample/expr_plus.py

Try this with another input file as well, such as `src/test/data/pa1/sample/coverage.py`, to see what happens when the results disagree.

## Assignment specifications

See the [PA1 specification][] on the course
website for a detailed specification of the assignment.

Refer to the [ChocoPy Specification][] on the CS164 web site
for the specification of the ChocoPy language. 

## Receiving updates to this repository

Add the `upstream` repository remotes (you only need to do this once in your local clone):

    git remote add upstream https://github.com/cs164berkeley/pa1-chocopy-parser.git

To sync with updates upstream:

    git pull upstream master


## Submission writeup

## Integrantes

- **Erik Alves de Moura Izidoro**  
- **Paulo Felipe Dos Santos Vieira**  
- **David Lopes de Santana Vazquez**

Este projeto foi desenvolvido para a disciplina de Compiladores da Universidade Federal Fluminense (UFF), ministrada pelo professor Christiano Braga no período 2025.1.

Agradecimentos especiais à **Sara Maia Cavalcante** (membra de outro grupo), cujas discussões contribuíram imensamente para a compreensão de aspectos importantes do trabalho.

Tempo estimado de desenvolvimento: **aproximadamente 72 horas**.

---

## 1. Que estratégia você usou para emitir tokens `INDENT` e `DEDENT` corretamente?  
**Mencione o nome do arquivo e o(s) número(s) da(s) linha(s) para a parte principal da sua solução.**

Para emitir corretamente os tokens `INDENT` e `DEDENT`, foi utilizada uma pilha de inteiros para rastrear os níveis de indentação, conforme descrito na especificação da linguagem ChocoPy. Essa lógica está implementada no arquivo `ChocoPy.jflex`, principalmente entre as **linhas 62 e 95**.
A cada nova linha lógica (detectada via `LineBreak`), o analisador muda para o estado `HANDLE_INDENTATION` (**linhas 198 a 211**), onde conta o número de espaços e tabulações iniciais (seguimos a dica do enunciado do trabalho que menciona a manipulação de estados do lexer com `%state`). 
A contagem é comparada com o topo da pilha:
- Se o novo nível for maior, um token `INDENT` é emitido e o novo valor é empilhado;
- Se for menor, tokens `DEDENT` são emitidos até que o nível da pilha corresponda ao nível atual.
O retorno ao estado `YYINITIAL` ocorre somente após o tratamento do primeiro `INDENT`, ou após detectar que não há alteração no nível de indentação.

---

## 2. Como sua solução ao item 1 se relaciona ao descrito na seção 3.1 do manual de referência de ChocoPy?

A estratégia de emissão de tokens `INDENT` e `DEDENT` está diretamente alinhada com a **seção 3.1.5 do manual de referência de ChocoPy**. Segundo o manual, a indentação é interpretada com base na contagem de espaços ou tabulações convertidas para múltiplos de oito, utilizando uma pilha para manter os níveis atuais. O código em `ChocoPy.jflex` implementa exatamente esse mecanismo: mantém uma pilha de níveis, gera `INDENT` quando há um aumento e `DEDENT` quando há uma redução, conforme requerido. Além disso, como descrito no manual, ao final do arquivo, `DEDENT`s restantes devem ser emitidos até esvaziar a pilha (exceto pelo nível zero inicial). Esse foi, inclusive, um dos maiores desafios durante a implementação da indentação.Foi necessária uma grande investigação nos métodos e nas variáveis da classe gerada pelo `.jflex` (o lexer) a fim de descobrir uma maneira de manipular o encerramento da leitura do arquivo. Quando o fim do arquivo era identificado, o código localizado em `<<EOF>>` era executado apenas uma vez (assim como é descrito no manual do JFlex), o que impedia mais de um retorno de um token `DEDENT`. Para resolver este problema, manipulamos diretamente a variável `zzAtEOF` (que indica final de arquivo), criando um pseudo-loop para emitir todos os tokens `DEDENT` restantes antes do *scanning* terminar.

---

## 3. Qual foi a característica mais difícil da linguagem (não incluindo indentação) neste projeto?  
**Por que foi um desafio? Mencione o nome do arquivo e o(s) número(s) da(s) linha(s) para a parte principal da sua solução.**

A linguagem em si não apresentou características muito desafiadoras com relação à compreensão, uma vez que possuíamos o **ChocoPy Language Reference** ao nosso favor. Como o documento era extremamente detalhado, foi consideravelmente simples construir a gramática da linguagem utilizando os **capítulos 2 e 4 como referência**. Sendo assim, o maior desafio da implementação consistiu na compreensão do gerador de parser. Compreender as classes das `astnodes`, juntamente aos seus métodos e especificações, acabou por demandar muito tempo do desenvolvimento do projeto.Todavia, uma vez que finalmente compreendemos como tudo funcionava, conseguimos construir a gramática rapidamente. A partir daí, verificamos cada um dos resultados obtidos ao rodar os testes (comparando nossas saídas com as saídas da implementação de referência) e fomos efetuando consertos conforme os erros iam aparecendo.

---
