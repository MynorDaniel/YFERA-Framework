%lex
%%

\s+                              /* ignorar espacios */
\/\*[\s\S]*?\*\/                 /* comentario de bloque */

"TABLE"     return 'TABLE';
"COLUMNS"   return 'COLUMNS';
"IN"        return 'IN';
"DELETE"    return 'DELETE';

"int"       return 'INT';
"float"     return 'FLOAT';
"string"    return 'STRING';
"boolean"   return 'BOOLEAN';
"char"      return 'CHAR';

"true"      return 'TRUE';
"false"     return 'FALSE';

"="         return 'IGUAL';
","         return 'COMA';
";"         return 'PUNTO_Y_COMA';
"."         return 'PUNTO';
"["         return 'CORCHETE_APERTURA';
"]"         return 'CORCHETE_CIERRE';

\'([^\'\\]|\\.)*\'    return 'CADENA_SIMPLE';
\"([^\"\\]|\\.)*\"    return 'CADENA';
[0-9]+\.[0-9]+        return 'DECIMAL';
[0-9]+                return 'ENTERO';
[a-zA-Z_][a-zA-Z0-9_-]*  return 'IDENTIFICADOR';

<<EOF>>   return 'EOF';
.         return 'INVALID';

/lex

%{
  var errores = [];
%}

%start s

%token TABLE COLUMNS IN DELETE
%token INT FLOAT STRING BOOLEAN CHAR
%token TRUE FALSE
%token IGUAL COMA PUNTO_Y_COMA PUNTO
%token CORCHETE_APERTURA CORCHETE_CIERRE
%token CADENA CADENA_SIMPLE DECIMAL ENTERO
%token IDENTIFICADOR
%token EOF INVALID

%%

s
  : programa EOF
    { return { tipo: 'Programa', elementos: $1, errores: errores }; }
  ;

programa
  : elementos
    { $$ = $1; }
  ;

elementos
  :
    { $$ = []; }
  | elementos elemento
    { $$ = $1.concat([$2]); }
  ;

elemento
  : create       { $$ = $1; }
  | select       { $$ = $1; }
  | insert       { $$ = $1; }
  | update       { $$ = $1; }
  | delete_inst  { $$ = $1; }
  | error PUNTO_Y_COMA
    {
      errores.push({ tipo: 'Error', linea: @1.first_line, mensaje: 'Instruccion invalida' });
      $$ = { tipo: 'Error', linea: @1.first_line };
    }
  ;

tipo
  : INT     { $$ = 'int'; }
  | FLOAT   { $$ = 'float'; }
  | STRING  { $$ = 'string'; }
  | BOOLEAN { $$ = 'boolean'; }
  | CHAR    { $$ = 'char'; }
  ;

/* ── CREATE ── */
create
  : TABLE IDENTIFICADOR COLUMNS columnas_tipos PUNTO_Y_COMA
    { $$ = { tipo: 'Create', tabla: $2, columnas: $4 }; }
  | TABLE error PUNTO_Y_COMA
    {
      errores.push({ tipo: 'Error', linea: @1.first_line, mensaje: 'Create TABLE mal formado' });
      $$ = { tipo: 'Error', linea: @1.first_line };
    }
  ;

columnas_tipos
  : columnas_tipos COMA columna_tipo
    { $$ = $1.concat([$3]); }
  | columna_tipo
    { $$ = [$1]; }
  ;

columna_tipo
  : IDENTIFICADOR IGUAL tipo
    { $$ = { columna: $1, tipo: $3 }; }
  ;

/* ── SELECT ── */
select
  : IDENTIFICADOR PUNTO IDENTIFICADOR PUNTO_Y_COMA
    { $$ = { tipo: 'Select', tabla: $1, columna: $3 }; }
  ;

/* ── INSERT ── */
insert
  : IDENTIFICADOR CORCHETE_APERTURA lista_asignaciones CORCHETE_CIERRE PUNTO_Y_COMA
    { $$ = { tipo: 'Insert', tabla: $1, asignaciones: $3 }; }
  | IDENTIFICADOR CORCHETE_APERTURA error CORCHETE_CIERRE PUNTO_Y_COMA
    {
      errores.push({ tipo: 'Error', linea: @1.first_line, mensaje: 'Insert mal formado en tabla "' + $1 + '"' });
      $$ = { tipo: 'Error', linea: @1.first_line };
    }
  ;

lista_asignaciones
  : lista_asignaciones COMA asignacion
    { $$ = $1.concat([$3]); }
  | asignacion
    { $$ = [$1]; }
  ;

asignacion
  : IDENTIFICADOR IGUAL literal
    { $$ = { campo: $1, valor: $3 }; }
  ;

literal
  : CADENA        { $$ = { tipo: 'Cadena',       valor: $1 }; }
  | CADENA_SIMPLE { $$ = { tipo: 'CadenaSimple', valor: $1 }; }
  | DECIMAL       { $$ = { tipo: 'Decimal',      valor: Number($1) }; }
  | ENTERO        { $$ = { tipo: 'Entero',       valor: Number($1) }; }
  | TRUE          { $$ = { tipo: 'Booleano',     valor: true }; }
  | FALSE         { $$ = { tipo: 'Booleano',     valor: false }; }
  ;

/* ── UPDATE ── */
update
  : IDENTIFICADOR CORCHETE_APERTURA lista_asignaciones CORCHETE_CIERRE IN ENTERO PUNTO_Y_COMA
    { $$ = { tipo: 'Update', tabla: $1, asignaciones: $3, indice: Number($6) }; }
  | IDENTIFICADOR CORCHETE_APERTURA error CORCHETE_CIERRE IN ENTERO PUNTO_Y_COMA
    {
      errores.push({ tipo: 'Error', linea: @1.first_line, mensaje: 'Update mal formado en tabla "' + $1 + '"' });
      $$ = { tipo: 'Error', linea: @1.first_line };
    }
  ;

/* ── DELETE ── */
delete_inst
  : IDENTIFICADOR DELETE ENTERO PUNTO_Y_COMA
    { $$ = { tipo: 'Delete', tabla: $1, indice: Number($3) }; }
  ;

