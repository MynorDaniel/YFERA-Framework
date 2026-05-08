%lex
%%

\s+                              /* ignorar espacios */
\/\*[\s\S]*?\*\/                 /* comentario de bloque */

"int"                          return 'INT';
"string"                          return 'STRING';
"function"                          return 'FUNCTION';
"boolean"                       return 'BOOLEAN'

"T"                          return 'TEXTO';
"IMG"                          return 'IMG';
"FORM"                          return 'FORM';
"INPUT_TEXT"                          return 'INPUT_TEXT';
"INPUT_NUMBER"                          return 'INPUT_NUMBER';
"INPUT_BOOL"                          return 'INPUT_BOOL';
"SUBMIT"                          return 'SUBMIT';
"id"                          return 'ID';
"label"                          return 'LABEL';
"value"                          return 'VALUE';

"for"                          return 'FOR';
"each"                          return 'EACH';
"track"                          return 'TRACK';
"empty"                          return 'EMPTY';
"if"                          return 'IF';
"else"                          return 'ELSE';
"Switch"                          return 'SWITCH';
"case"                          return 'CASE';
"default"                          return 'DEFAULT';


"true" return 'TRUE';
"false" return 'FALSE';

"("   return 'PAREN_IZQ';
")"   return 'PAREN_DER';
"+"   return 'MAS';
"-"   return 'MENOS';
"*"   return 'POR';
"/"   return 'ENTRE';

"{"   return 'LLAVE_APERTURA';
"}"   return 'LLAVE_CIERRE';
"["   return 'CORCHETE_APERTURA';
"]"   return 'CORCHETE_CIERRE';
","   return 'COMA';
"$"   return 'DOLAR';
":"   return 'DOS_PUNTOS';
"@"   return 'ARROBA';

"<="  return 'MENOR_IGUAL';
">="  return 'MAYOR_IGUAL';
">"   return 'MAYOR_QUE';
"<"   return 'MENOR_QUE';
"=="  return 'IGUALDAD';
"!="  return 'DIFERENTE';
"="   return 'IGUAL';

"||"  return 'OR';
"&&"  return 'AND';
"!"   return 'NEGACION';

\"([^\"\\]|\\.|[\n\r])*\"   return 'CADENA';
[0-9]+                 return 'ENTERO';
"%"                    return 'MODULO';
[a-zA-Z0-9_-]+         return 'IDENTIFICADOR';

<<EOF>>   return 'EOF';
.         return 'INVALID';

/lex

%{
%}

%start s

%token INT STRING FUNCTION TEXTO IMG FORM
%token INPUT_TEXT INPUT_NUMBER INPUT_BOOL SUBMIT
%token ID LABEL VALUE

%token FOR EACH TRACK EMPTY IF ELSE SWITCH CASE DEFAULT

%token TRUE FALSE

%token PAREN_IZQ PAREN_DER
%token MAS MENOS POR ENTRE MODULO

%token LLAVE_APERTURA LLAVE_CIERRE
%token CORCHETE_APERTURA CORCHETE_CIERRE
%token COMA DOLAR DOS_PUNTOS ARROBA

%token MENOR_IGUAL MAYOR_IGUAL MAYOR_QUE MENOR_QUE
%token IGUALDAD DIFERENTE IGUAL

%token OR AND NEGACION

%token CADENA ENTERO IDENTIFICADOR

%token EOF INVALID

%left OR
%left AND
%left IGUALDAD DIFERENTE
%left MENOR_QUE MENOR_IGUAL MAYOR_QUE MAYOR_IGUAL
%left MAS MENOS
%left POR ENTRE MODULO
%right NEGACION
%right UMINUS

%%

s : programa EOF ;

programa
  : componentes
  ;

componentes
  : componentes componente
  | 
  ;

componente : IDENTIFICADOR PAREN_IZQ parametros_componente PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE;

parametros_componente
  :
  | lista_parametros
  ;

lista_parametros
  : lista_parametros COMA parametro
  | parametro
  ;


elementos
  : elementos elemento
  | 
  ;

parametro: tipo IDENTIFICADOR;

tipo: INT | STRING | FUNCTION | BOOLEAN;

elemento: seccion | tabla | texto | imagen | formulario | for | if | switch;

seccion: estilos_elemento CORCHETE_APERTURA elementos CORCHETE_CIERRE;

tabla: estilos_elemento CORCHETE_APERTURA CORCHETE_APERTURA lista_tr CORCHETE_CIERRE CORCHETE_CIERRE;

lista_tr
  :
  | lista_tr tr
  ;

tr: CORCHETE_APERTURA CORCHETE_APERTURA lista_td CORCHETE_CIERRE CORCHETE_CIERRE;

lista_td
  :
  | lista_td td
  ;

td: CORCHETE_APERTURA CORCHETE_APERTURA elementos CORCHETE_CIERRE CORCHETE_CIERRE;

texto: TEXTO estilos_elemento PAREN_IZQ concatenacion PAREN_DER;

concatenacion
  : concatenacion MAS valor_concat
  | valor_concat
  |
  ;

valor_concat
  : CADENA
  | DOLAR IDENTIFICADOR
  | ENTERO
  | TRUE | FALSE
  ;

imagen: IMG estilos_elemento PAREN_IZQ urls PAREN_DER;

urls
  : urls COMA url
  | url
  ;

url: CADENA | DOLAR IDENTIFICADOR;

formulario: FORM estilos_elemento LLAVE_APERTURA elementos_formulario LLAVE_CIERRE submit;

elementos_formulario
  :
  | elementos_formulario elemento_formulario
  ;

elemento_formulario: input_text | input_number | input_bool;

input_text: INPUT_TEXT contenido_input;

input_number: INPUT_NUMBER contenido_input;

input_bool: INPUT_BOOL contenido_input;

contenido_input: estilos_elemento PAREN_IZQ ID DOS_PUNTOS valor_concat COMA LABEL DOS_PUNTOS valor_concat COMA VALUE DOS_PUNTOS valor_concat PAREN_DER;

estilos_elemento: MENOR_QUE lista_clases MAYOR_QUE | ;

lista_clases
  : lista_clases COMA clase
  | clase
  ;

clase: IDENTIFICADOR;

submit: SUBMIT estilos_elemento LLAVE_APERTURA LABEL DOS_PUNTOS valor_concat FUNCTION DOS_PUNTOS funcion LLAVE_CIERRE | ;

funcion: DOLAR IDENTIFICADOR PAREN_IZQ parametros_funcion PAREN_DER;

parametros_funcion
  :
  | lista_parametros_funcion
  ;

lista_parametros_funcion
  : lista_parametros_funcion COMA parametro_funcion
  | parametro_funcion
  ;

parametro_funcion: ARROBA IDENTIFICADOR;


for: FOR EACH PAREN_IZQ DOLAR IDENTIFICADOR DOS_PUNTOS DOLAR IDENTIFICADOR PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    | FOR PAREN_IZQ DOLAR IDENTIFICADOR DOS_PUNTOS DOLAR IDENTIFICADOR COMA DOLAR IDENTIFICADOR DOS_PUNTOS DOLAR IDENTIFICADOR PAREN_DER TRACK DOLAR IDENTIFICADOR LLAVE_APERTURA elementos LLAVE_CIERRE empty;

empty: EMPTY LLAVE_APERTURA elementos LLAVE_CIERRE | ;

if: IF PAREN_IZQ condicion PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE lista_elseif lista_else;

lista_elseif
  :
  | lista_elseif elseif
  ;

lista_else
  :
  | lista_else else
  ;

elseif: ELSE PAREN_IZQ condicion PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE;

else: ELSE LLAVE_APERTURA elementos LLAVE_CIERRE;

condicion
  : condicion OR condicion_and
  | condicion_and
  ;

condicion_and
  : condicion_and AND condicion_not
  | condicion_not
  ;

condicion_not
  : NEGACION condicion_not
  | condicion_base
  ;

condicion_base
  : valor_concat simbolo_comparacion valor_concat
  | valor_concat
  | PAREN_IZQ condicion PAREN_DER
  ;

simbolo_comparacion
  : IGUALDAD
  | DIFERENTE
  | MAYOR_QUE
  | MENOR_QUE
  | MAYOR_IGUAL
  | MENOR_IGUAL
  ;

switch: SWITCH PAREN_IZQ valor_concat PAREN_DER LLAVE_APERTURA cases COMA default LLAVE_CIERRE;

cases
  : cases COMA case
  | case
  ;

case: valor_case LLAVE_APERTURA elementos LLAVE_CIERRE;

valor_case: ENTERO | concatenacion;

default: LLAVE_APERTURA elementos LLAVE_CIERRE | ;





























