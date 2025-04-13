package chocopy.pa1;
import java_cup.runtime.*;
import java.util.Stack;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column

%class ChocoPyLexer
%public

%cupsym ChocoPyTokens
%cup
%cupdebug

%state HANDLE_INDENTATION

%eofclose false

/*** Do not change the flags above unless you know what you are doing. ***/

/* The following code section is copied verbatim to the
 * generated lexer class. */
%{
    /* The code below includes some convenience methods to create tokens
     * of a given type and optionally a value that the CUP parser can
     * understand. Specifically, a lot of the logic below deals with
     * embedded information about where in the source code a given token
     * was recognized, so that the parser can report errors accurately.
     * (It need not be modified for this project.) */

    /** Producer of token-related values for the parser. */
    final ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();

    /** Return a terminal symbol of syntactic category TYPE and no
     *  semantic value at the current source location. */
    private Symbol symbol(int type) {
        return symbol(type, yytext());
    }

    /** Return a terminal symbol of syntactic category TYPE and semantic
     *  value VALUE at the current source location. */
    private Symbol symbol(int type, Object value) {
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            value);
    }

    /* funcao auxiliar para emitir o token indent no inicio da linha (atendendo assim o caso bad_indentation.py) */
    private Symbol indentSymbol(int type, Object value) {
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn - 1),
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + yylength()),
            value);
    }

    // Pilha para controlar os niveis de indentacao
    private Stack<Integer> indentationStack = new Stack<>();
    { indentationStack.push(0); } // Inicializa com 0 segundo o chocopy language reference

    // Variável para armazenar a indentação atual
    private int currentIndent = 0;

    // Metodo para adicionar "\t" no nivel de indentacao
    private void addTab (){
        currentIndent += 8; // equivale a 8 whitespaces segundo o lang ref
    }

    // Metodo para adicionar " " no nivel de indentacao   
    private void addSpace(){
        currentIndent++;
    }

    // Metodo para gerar os simbolos. Volta para o estado inicial ao gerar um simbolo INDENT.
    // Nao volta para o estado inicial ao gerar um simbolo DEDENT ja que pode ser necessario gerar mais de um.
    private Symbol geraDent(){
        if(currentIndent > indentationStack.peek()){
            indentationStack.push(currentIndent);
            yypushback(1);
            yybegin(YYINITIAL);
            return indentSymbol(ChocoPyTokens.INDENT, yytext());
        }
        else if(currentIndent < indentationStack.peek()){
            yypushback(1);
            indentationStack.pop();
            return symbol(ChocoPyTokens.DEDENT);
        }
        
        return null;
    }

%}

/* Macros (regexes used in rules below) */

WhiteSpace = [ \t]

LineBreak  = \r|\n|\r\n

Identifier = [a-zA-Z_][a-zA-Z_0-9]*

IntegerLiteral = 0 | [1-9][0-9]*

StringLiteral = \"(\\.|[^\"\\\t\n])*\" 

Comment = #.* // tokens de comentario removidos pois nao devem ser emitidos pelo lexer


%%

<YYINITIAL> {
  

  /* Delimiters. */
  {LineBreak}                 { 
                                yybegin(HANDLE_INDENTATION); 
                                currentIndent = 0; 
                                return symbol(ChocoPyTokens.NEWLINE); 
                              }

  {LineBreak}([ \t]*(#.*)?(\r|\n|\r\n))+ {
                                            yybegin(HANDLE_INDENTATION); 
                                            currentIndent = 0; 
                                            return symbol(ChocoPyTokens.NEWLINE); 
                                            /* lidando com uma quebra de linha seguida de uma ou mais linhas 
                                            * que podem conter so espacos e tabs, um comentário opcional e que
                                            * terminam com uma quebra de linha (resolve o problema dos tokens UNRECOGNIZED
                                            * emitidos nesses casos) */
                                         }

  /* Literals. */
  {IntegerLiteral}            { return symbol(ChocoPyTokens.NUMBER,
                                                 Integer.parseInt(yytext())); }
  {StringLiteral}             { return symbol(ChocoPyTokens.STRING, yytext().substring(1, yytext().length() - 1)); /* necessaria retirada das contrabarras */}

  /* Keywords */
  // terminais que nao sao strings corrigidos
  // foi necessario retirar alguns terminais por falta de uso. os terminais retirados estao indicados no .cup
  
  "False"                     { return symbol(ChocoPyTokens.BOOL, false); }
  "None"                      { return symbol(ChocoPyTokens.NONE); }
  "True"                      { return symbol(ChocoPyTokens.BOOL, true); }
  "and"                       { return symbol(ChocoPyTokens.AND); }
  "class"                     { return symbol(ChocoPyTokens.CLASS); }
  "def"                       { return symbol(ChocoPyTokens.DEF); }
  "elif"                      { return symbol(ChocoPyTokens.ELIF); }
  "else"                      { return symbol(ChocoPyTokens.ELSE); }
  "for"                       { return symbol(ChocoPyTokens.FOR); }
  "global"                    { return symbol(ChocoPyTokens.GLOBAL); }
  "if"                        { return symbol(ChocoPyTokens.IF); }
  "in"                        { return symbol(ChocoPyTokens.IN); }
  "is"                        { return symbol(ChocoPyTokens.IS); }
  "nonlocal"                  { return symbol(ChocoPyTokens.NONLOCAL); }
  "not"                       { return symbol(ChocoPyTokens.NOT); }
  "or"                        { return symbol(ChocoPyTokens.OR); }
  "pass"                      { return symbol(ChocoPyTokens.PASS); }
  "return"                    { return symbol(ChocoPyTokens.RETURN); }
  "while"                     { return symbol(ChocoPyTokens.WHILE); }


  /* Operators. */
  "+"                         { return symbol(ChocoPyTokens.PLUS, yytext()); }
  "-"                         { return symbol(ChocoPyTokens.MINUS, yytext()); }
  "*"                         { return symbol(ChocoPyTokens.TIMES, yytext()); }
  "//"                        { return symbol(ChocoPyTokens.DIVISION, yytext()); }
  "%"                         { return symbol(ChocoPyTokens.MOD, yytext()); }
  "<"                         { return symbol(ChocoPyTokens.LESS_THAN, yytext()); }
  ">"                         { return symbol(ChocoPyTokens.GREATER_THAN, yytext()); }
  "<="                        { return symbol(ChocoPyTokens.LESS_THAN_EQUAL_TO, yytext()); }
  ">="                        { return symbol(ChocoPyTokens.GREATER_THAN_EQUAL_TO, yytext());}
  "=="                        { return symbol(ChocoPyTokens.EQUAL_TO, yytext()); }
  "!="                        { return symbol(ChocoPyTokens.NOT_EQUAL_TO, yytext()); }
  "="                         { return symbol(ChocoPyTokens.EQUAL, yytext()); }
  "("                         { return symbol(ChocoPyTokens.LEFT_PARENTHESIS, yytext()); }
  ")"                         { return symbol(ChocoPyTokens.RIGHT_PARENTHESIS, yytext()); }
  "["                         { return symbol(ChocoPyTokens.LEFT_BRACKET, yytext()); }
  "]"                         { return symbol(ChocoPyTokens.RIGHT_BRACKET, yytext()); }
  ","                         { return symbol(ChocoPyTokens.COMMA, yytext()); }
  ":"                         { return symbol(ChocoPyTokens.COLON, yytext()); }
  "->"                        { return symbol(ChocoPyTokens.RIGHT_ARROW, yytext()); }
  "."                         { return symbol(ChocoPyTokens.DOT, yytext()); }

  /* Whitespace. */
  {WhiteSpace}                { /* ignore */ }

  /* Identifiers */
  {Identifier}                { return symbol(ChocoPyTokens.IDSTRING, yytext()); /* token identifier e nao terminal, necessita de conversao */ } 

  /* Comments */
  {Comment}                   { /* nao devem ser emitidos pelo lexer */}
}

<HANDLE_INDENTATION> {
  " "                         { addSpace(); }
  \t                          { addTab(); }
  .                           { 
                                if(indentationStack.peek() != currentIndent){ // verifica se o nivel de indentacao mudou
                                    return geraDent(); // caso tenha mudado, decide o simbolo a ser retornado
                                } 
                                else { // caso nao tenha mudado, devolve o caracter lido e volta para o estado inicial
                                    yypushback(1); 
                                    yybegin(YYINITIAL);
                                } 
                              }

}

<<EOF>> {
    if(indentationStack.peek() > 0){
        indentationStack.pop();
        zzAtEOF = false; // reseta variavel que indica end of file, possibilitando loop
        return symbol(ChocoPyTokens.DEDENT);
    }
    return symbol(ChocoPyTokens.EOF); 
}

/* Error fallback. */
[^]                           { return symbol(ChocoPyTokens.UNRECOGNIZED); }