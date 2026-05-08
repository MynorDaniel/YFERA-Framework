%lex
%%

\s+                              /* ignorar espacios */
\/\*[\s\S]*?\*\/                 /* comentario de bloque */

"TABLE"       return 'TABLE';
"COLUMNS"       return 'COLUMNS';
"IN"            return 'IN';
"DELETE"            return 'DELETE';


"int"   return 'INT';
"float" return 'FLOAT';
"string"    return 'STRING';
"boolean"   return 'BOOLEAN';
"char"  return 'CHAR';

"="  return 'IGUAL';
","  return 'COMA';
";"  return 'PUNTO_Y_COMA';
"."  return 'PUNTO';
"["  return 'CORCHETE_APERTURA';
"]"  return 'CORCHETE_CIERRE';


\"([^\"\\]|\\.)*\"    return 'CADENA';
[0-9]+\.[0-9]+        return 'DECIMAL';
[0-9]+                return 'ENTERO';

[a-zA-Z_][a-zA-Z0-9_-]*  return 'IDENTIFICADOR';

<<EOF>>   return 'EOF';
.         return 'INVALID';

/lex

%{
%}

%start s

%token TABLE COLUMNS IN DELETE

%token INT FLOAT STRING BOOLEAN CHAR

%token IGUAL COMA PUNTO_Y_COMA PUNTO
%token CORCHETE_APERTURA CORCHETE_CIERRE

%token CADENA DECIMAL ENTERO
%token IDENTIFICADOR

%token EOF INVALID

%%

s
  : programa EOF
  ;

programa: elementos

elementos
  :
  | elementos elemento
  ;

elemento: create | select | insert | update | delete;

tipo: INT | FLOAT | STRING | BOOLEAN | CHAR;





















































