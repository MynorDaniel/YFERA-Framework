%lex
%%

\s+                              /* ignorar espacios */
\/\*[\s\S]*?\*\/                 /* comentario de bloque */

"int"           return 'INT';
"string"        return 'STRING';
"function"      return 'FUNCTION';
"boolean"       return 'BOOLEAN';

"T"             return 'TEXTO';
"IMG"           return 'IMG';
"FORM"          return 'FORM';
"INPUT_TEXT"    return 'INPUT_TEXT';
"INPUT_NUMBER"  return 'INPUT_NUMBER';
"INPUT_BOOL"    return 'INPUT_BOOL';
"SUBMIT"        return 'SUBMIT';
"id"            return 'ID';
"label"         return 'LABEL';
"value"         return 'VALUE';

"for"           return 'FOR';
"each"          return 'EACH';
"track"         return 'TRACK';
"empty"         return 'EMPTY';
"if"            return 'IF';
"else"          return 'ELSE';
"Switch"        return 'SWITCH';
"case"          return 'CASE';
"default"       return 'DEFAULT';

"true"          return 'TRUE';
"false"         return 'FALSE';

"("   return 'PAREN_IZQ';
")"   return 'PAREN_DER';
"+"   return 'MAS';
"-"   return 'MENOS';
"*"   return 'POR';
"/"   return 'ENTRE';
"%"   return 'MODULO';

"{"   return 'LLAVE_APERTURA';
"}"   return 'LLAVE_CIERRE';
"[["  return 'DCORCHETE_APERTURA';
"]]"  return 'DCORCHETE_CIERRE';
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

"<"[a-zA-Z_][a-zA-Z0-9_,\s-]*">"   return 'BLOQUE_ESTILOS';

\`[^`]*\`              return 'EXPRESION_BACKTICK';
\"([^\"\\]|\\.)*\"    return 'CADENA';
[0-9]+                return 'ENTERO';
[a-zA-Z_][a-zA-Z0-9_-]*  return 'IDENTIFICADOR';

<<EOF>>   return 'EOF';
.         return 'INVALID';

/lex

%{
  var errores = [];
  function regError(linea, msg) {
    errores.push({ linea: linea, mensaje: msg });
  }
%}

%start s

%token INT STRING FUNCTION BOOLEAN
%token TEXTO IMG FORM INPUT_TEXT INPUT_NUMBER INPUT_BOOL SUBMIT
%token ID LABEL VALUE
%token FOR EACH TRACK EMPTY IF ELSE SWITCH CASE DEFAULT
%token TRUE FALSE
%token PAREN_IZQ PAREN_DER MAS MENOS POR ENTRE MODULO
%token LLAVE_APERTURA LLAVE_CIERRE
%token DCORCHETE_APERTURA DCORCHETE_CIERRE
%token CORCHETE_APERTURA CORCHETE_CIERRE
%token COMA DOLAR DOS_PUNTOS ARROBA
%token MENOR_IGUAL MAYOR_IGUAL MAYOR_QUE MENOR_QUE IGUALDAD DIFERENTE IGUAL
%token OR AND NEGACION
%token CADENA ENTERO EXPRESION_BACKTICK IDENTIFICADOR
%token BLOQUE_ESTILOS
%token EOF INVALID

%left OR
%left AND
%left IGUALDAD DIFERENTE
%left MENOR_QUE MENOR_IGUAL MAYOR_QUE MAYOR_IGUAL
%left MAS MENOS
%left POR ENTRE MODULO
%right NEGACION

%%

s
  : programa EOF
    { return { tipo: 'Programa', componentes: $1, errores: errores }; }
  ;

programa
  : componentes
    { $$ = $1; }
  ;

componentes
  : componentes componente
    { $$ = $1.concat([$2]); }
  | componentes error LLAVE_CIERRE
    {
      regError(@2.first_line, 'Componente mal formado');
      $$ = $1.concat([{ tipo: 'Error', linea: @2.first_line }]);
    }
  |
    { $$ = []; }
  ;

componente
  : IDENTIFICADOR PAREN_IZQ parametros_componente PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'Componente', nombre: $1, parametros: $3, elementos: $6 }; }
  | IDENTIFICADOR PAREN_IZQ error PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    {
      regError(@3.first_line, 'Parametros invalidos en componente "' + $1 + '"');
      $$ = { tipo: 'Componente', nombre: $1, parametros: [], elementos: $6 };
    }
  ;

parametros_componente
  :
    { $$ = []; }
  | lista_parametros
    { $$ = $1; }
  ;

lista_parametros
  : lista_parametros COMA parametro
    { $$ = $1.concat([$3]); }
  | lista_parametros COMA error
    {
      regError(@3.first_line, 'Parametro mal formado');
      $$ = $1;
    }
  | parametro
    { $$ = [$1]; }
  ;

parametro
  : tipo IDENTIFICADOR
    { $$ = { tipo: $1, nombre: $2 }; }
  ;

tipo
  : INT      { $$ = 'int'; }
  | STRING   { $$ = 'string'; }
  | FUNCTION { $$ = 'function'; }
  | BOOLEAN  { $$ = 'boolean'; }
  ;

elementos
  : elementos elemento
    { $$ = $1.concat([$2]); }
  | elementos error LLAVE_CIERRE
    {
      regError(@2.first_line, 'Elemento invalido, se esperaba seccion/texto/imagen/formulario/for/if/switch');
      $$ = $1.concat([{ tipo: 'Error', linea: @2.first_line }]);
    }
  |
    { $$ = []; }
  ;

elemento
  : seccion     { $$ = $1; }
  | tabla       { $$ = $1; }
  | texto       { $$ = $1; }
  | imagen      { $$ = $1; }
  | formulario  { $$ = $1; }
  | ciclo_for   { $$ = $1; }
  | cond_if     { $$ = $1; }
  | cond_switch { $$ = $1; }
  ;

/* ── Sección ── */
seccion
  : estilos_elemento CORCHETE_APERTURA elementos CORCHETE_CIERRE
    { $$ = { tipo: 'Seccion', estilos: $1, elementos: $3 }; }

  ;

/* ── Tabla ── */
tabla
  : estilos_elemento DCORCHETE_APERTURA lista_tr DCORCHETE_CIERRE
    { $$ = { tipo: 'Tabla', estilos: $1, filas: $3 }; }

  ;

lista_tr
  : lista_tr tr
    { $$ = $1.concat([$2]); }
  | lista_tr error DCORCHETE_CIERRE
    {
      regError(@2.first_line, 'Fila de tabla mal formada');
      $$ = $1;
    }
  |
    { $$ = []; }
  ;

tr
  : DCORCHETE_APERTURA lista_td DCORCHETE_CIERRE
    { $$ = { tipo: 'Fila', celdas: $2 }; }
  | DCORCHETE_APERTURA error DCORCHETE_CIERRE
    {
      regError(@2.first_line, 'Celda de fila mal formada');
      $$ = { tipo: 'Fila', celdas: [] };
    }
  ;

lista_td
  : lista_td td
    { $$ = $1.concat([$2]); }
  |
    { $$ = []; }
  ;

td
  : DCORCHETE_APERTURA elementos DCORCHETE_CIERRE
    { $$ = { tipo: 'Celda', elementos: $2 }; }

  ;

/* ── Texto ── */
texto
  : TEXTO estilos_elemento PAREN_IZQ contenido_texto PAREN_DER
    { $$ = { tipo: 'Texto', estilos: $2, contenido: $4 }; }
  | TEXTO estilos_elemento PAREN_IZQ error PAREN_DER
    {
      regError(@4.first_line, 'Contenido de texto invalido');
      $$ = { tipo: 'Texto', estilos: $2, contenido: [] };
    }
  ;

contenido_texto
  : lista_concat
    { $$ = $1; }
  |
    { $$ = []; }
  ;

lista_concat
  : lista_concat MAS parte_texto
    { $$ = $1.concat([$3]); }
  | lista_concat MAS error
    {
      regError(@3.first_line, 'Parte de concatenacion invalida');
      $$ = $1;
    }
  | parte_texto
    { $$ = [$1]; }
  ;

parte_texto
  : CADENA
    { $$ = { tipo: 'Cadena', valor: $1 }; }
  | DOLAR IDENTIFICADOR
    { $$ = { tipo: 'Variable', nombre: $2 }; }
  | ENTERO
    { $$ = { tipo: 'Entero', valor: Number($1) }; }
  | TRUE
    { $$ = { tipo: 'Booleano', valor: true }; }
  | FALSE
    { $$ = { tipo: 'Booleano', valor: false }; }
  | EXPRESION_BACKTICK
    { $$ = { tipo: 'Expresion', valor: $1 }; }
  ;

/* ── Imagen ── */
imagen
  : IMG estilos_elemento PAREN_IZQ lista_urls PAREN_DER
    { $$ = { tipo: 'Imagen', estilos: $2, urls: $4 }; }
  | IMG estilos_elemento PAREN_IZQ error PAREN_DER
    {
      regError(@4.first_line, 'URLs de imagen invalidas');
      $$ = { tipo: 'Imagen', estilos: $2, urls: [] };
    }
  ;

lista_urls
  : lista_urls COMA url_item
    { $$ = $1.concat([$3]); }
  | lista_urls COMA error
    {
      regError(@3.first_line, 'URL invalida en lista de imagenes');
      $$ = $1;
    }
  | url_item
    { $$ = [$1]; }
  ;

url_item
  : CADENA
    { $$ = { tipo: 'Cadena', valor: $1 }; }
  | DOLAR IDENTIFICADOR
    { $$ = { tipo: 'Variable', nombre: $2 }; }
  ;

/* ── Formulario ── */
formulario
  : FORM estilos_elemento LLAVE_APERTURA elementos_formulario LLAVE_CIERRE bloque_submit
    { $$ = { tipo: 'Formulario', estilos: $2, inputs: $4, submit: $6 }; }

  ;

elementos_formulario
  : elementos_formulario elemento_formulario
    { $$ = $1.concat([$2]); }
  | elementos_formulario error PAREN_DER
    {
      regError(@2.first_line, 'Input de formulario mal formado');
      $$ = $1;
    }
  |
    { $$ = []; }
  ;

elemento_formulario
  : input_text   { $$ = $1; }
  | input_number { $$ = $1; }
  | input_bool   { $$ = $1; }
  ;

input_text
  : INPUT_TEXT contenido_input
    { $$ = { tipo: 'InputText', attrs: $2 }; }
  | INPUT_TEXT error PAREN_DER
    {
      regError(@2.first_line, 'INPUT_TEXT mal formado');
      $$ = { tipo: 'InputText', attrs: null };
    }
  ;

input_number
  : INPUT_NUMBER contenido_input
    { $$ = { tipo: 'InputNumber', attrs: $2 }; }
  | INPUT_NUMBER error PAREN_DER
    {
      regError(@2.first_line, 'INPUT_NUMBER mal formado');
      $$ = { tipo: 'InputNumber', attrs: null };
    }
  ;

input_bool
  : INPUT_BOOL contenido_input
    { $$ = { tipo: 'InputBool', attrs: $2 }; }
  | INPUT_BOOL error PAREN_DER
    {
      regError(@2.first_line, 'INPUT_BOOL mal formado');
      $$ = { tipo: 'InputBool', attrs: null };
    }
  ;

contenido_input
  : estilos_elemento PAREN_IZQ ID DOS_PUNTOS parte_texto COMA LABEL DOS_PUNTOS parte_texto COMA VALUE DOS_PUNTOS parte_texto PAREN_DER
    { $$ = { estilos: $1, id: $5, label: $9, value: $13 }; }
  | estilos_elemento PAREN_IZQ error PAREN_DER
    {
      regError(@3.first_line, 'Atributos de input invalidos, se esperaba id:..., label:..., value:...');
      $$ = { estilos: $1, id: null, label: null, value: null };
    }
  ;

bloque_submit
  : SUBMIT estilos_elemento LLAVE_APERTURA LABEL DOS_PUNTOS parte_texto FUNCTION DOS_PUNTOS llamada_funcion LLAVE_CIERRE
    { $$ = { tipo: 'Submit', estilos: $2, label: $6, funcion: $9 }; }
  | SUBMIT estilos_elemento LLAVE_APERTURA error LLAVE_CIERRE
    {
      regError(@4.first_line, 'Contenido de SUBMIT invalido, se esperaba label:... function:...');
      $$ = { tipo: 'Submit', estilos: $2, label: null, funcion: null };
    }
  |
    { $$ = null; }
  ;

llamada_funcion
  : DOLAR IDENTIFICADOR PAREN_IZQ lista_args PAREN_DER
    { $$ = { tipo: 'LlamadaFuncion', nombre: $2, args: $4 }; }
  | DOLAR IDENTIFICADOR PAREN_IZQ error PAREN_DER
    {
      regError(@4.first_line, 'Argumentos de funcion invalidos en "' + $2 + '"');
      $$ = { tipo: 'LlamadaFuncion', nombre: $2, args: [] };
    }
  ;

lista_args
  : lista_args COMA arg_funcion
    { $$ = $1.concat([$3]); }
  | lista_args COMA error
    {
      regError(@3.first_line, 'Argumento de funcion invalido');
      $$ = $1;
    }
  | arg_funcion
    { $$ = [$1]; }
  |
    { $$ = []; }
  ;

arg_funcion
  : ARROBA IDENTIFICADOR
    { $$ = { tipo: 'ArgInput', nombre: $2 }; }
  ;

/* ── Estilos ── */
estilos_elemento
  : BLOQUE_ESTILOS
    { $$ = $1.slice(1,$1.length-1).split(',').map(function(s){return s.trim();}).filter(Boolean); }
  |
    { $$ = []; }
  ;

/* ── For ── */
ciclo_for
  : FOR EACH PAREN_IZQ DOLAR IDENTIFICADOR DOS_PUNTOS DOLAR IDENTIFICADOR PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'ForEach', array: $5, item: $8, elementos: $12, empty: null }; }
  | FOR EACH PAREN_IZQ error PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    {
      regError(@4.first_line, 'Expresion de for each invalida, se esperaba ($array : $item)');
      $$ = { tipo: 'ForEach', array: null, item: null, elementos: $7, empty: null };
    }
  | FOR PAREN_IZQ DOLAR IDENTIFICADOR DOS_PUNTOS DOLAR IDENTIFICADOR COMA DOLAR IDENTIFICADOR DOS_PUNTOS DOLAR IDENTIFICADOR PAREN_DER TRACK DOLAR IDENTIFICADOR LLAVE_APERTURA elementos LLAVE_CIERRE bloque_empty
    { $$ = { tipo: 'ForDoble', array1: $4, item1: $7, array2: $10, item2: $13, track: $17, elementos: $19, empty: $21 }; }
  | FOR PAREN_IZQ error PAREN_DER TRACK DOLAR IDENTIFICADOR LLAVE_APERTURA elementos LLAVE_CIERRE bloque_empty
    {
      regError(@3.first_line, 'Expresion de for doble invalida');
      $$ = { tipo: 'ForDoble', array1: null, item1: null, array2: null, item2: null, track: $7, elementos: $9, empty: $11 };
    }
  ;

bloque_empty
  : EMPTY LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'Empty', elementos: $3 }; }

  |
    { $$ = null; }
  ;

/* ── If ── */
cond_if
  : IF PAREN_IZQ condicion PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE lista_elseif bloque_else
    { $$ = { tipo: 'If', condicion: $3, entonces: $6, elseifs: $8, sino: $9 }; }
  | IF PAREN_IZQ error PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE lista_elseif bloque_else
    {
      regError(@3.first_line, 'Condicion de if invalida');
      $$ = { tipo: 'If', condicion: null, entonces: $6, elseifs: $8, sino: $9 };
    }
  ;

lista_elseif
  : lista_elseif bloque_elseif
    { $$ = $1.concat([$2]); }
  |
    { $$ = []; }
  ;

bloque_elseif
  : ELSE PAREN_IZQ condicion PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'ElseIf', condicion: $3, elementos: $6 }; }
  | ELSE PAREN_IZQ error PAREN_DER LLAVE_APERTURA elementos LLAVE_CIERRE
    {
      regError(@3.first_line, 'Condicion de else-if invalida');
      $$ = { tipo: 'ElseIf', condicion: null, elementos: $6 };
    }
  ;

bloque_else
  : ELSE LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'Else', elementos: $3 }; }

  |
    { $$ = null; }
  ;

condicion
  : condicion OR condicion_and
    { $$ = { tipo: 'CondOr', izq: $1, der: $3 }; }
  | condicion_and
    { $$ = $1; }
  ;

condicion_and
  : condicion_and AND condicion_not
    { $$ = { tipo: 'CondAnd', izq: $1, der: $3 }; }
  | condicion_not
    { $$ = $1; }
  ;

condicion_not
  : NEGACION condicion_not
    { $$ = { tipo: 'CondNot', valor: $2 }; }
  | condicion_base
    { $$ = $1; }
  ;

condicion_base
  : parte_texto op_comparacion parte_texto
    { $$ = { tipo: 'Comparacion', izq: $1, op: $2, der: $3 }; }
  | parte_texto
    { $$ = { tipo: 'CondValor', valor: $1 }; }
  | PAREN_IZQ condicion PAREN_DER
    { $$ = $2; }
  ;

op_comparacion
  : IGUALDAD    { $$ = '=='; }
  | DIFERENTE   { $$ = '!='; }
  | MAYOR_QUE   { $$ = '>'; }
  | MENOR_QUE   { $$ = '<'; }
  | MAYOR_IGUAL { $$ = '>='; }
  | MENOR_IGUAL { $$ = '<='; }
  ;

/* ── Switch ── */
cond_switch
  : SWITCH PAREN_IZQ parte_texto PAREN_DER LLAVE_APERTURA lista_cases bloque_default LLAVE_CIERRE
    { $$ = { tipo: 'Switch', valor: $3, casos: $6, defecto: $7 }; }
  | SWITCH PAREN_IZQ error PAREN_DER LLAVE_APERTURA lista_cases bloque_default LLAVE_CIERRE
    {
      regError(@3.first_line, 'Valor de Switch invalido');
      $$ = { tipo: 'Switch', valor: null, casos: $6, defecto: $7 };
    }
  ;

lista_cases
  : lista_cases COMA bloque_case
    { $$ = $1.concat([$3]); }
  | lista_cases COMA error LLAVE_CIERRE
    {
      regError(@3.first_line, 'Case mal formado');
      $$ = $1;
    }
  | bloque_case
    { $$ = [$1]; }
  ;

bloque_case
  : CASE parte_texto LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'Case', valor: $2, elementos: $4 }; }
  | CASE error LLAVE_APERTURA elementos LLAVE_CIERRE
    {
      regError(@2.first_line, 'Valor de case invalido');
      $$ = { tipo: 'Case', valor: null, elementos: $4 };
    }

  ;

bloque_default
  : COMA DEFAULT LLAVE_APERTURA elementos LLAVE_CIERRE
    { $$ = { tipo: 'Default', elementos: $4 }; }

  |
    { $$ = null; }
  ;
