%lex
%%

\s+                              /* ignorar espacios */
\/\*[\s\S]*?\*\/                 /* comentario de bloque */

"height"                          return 'HEIGHT';
"width"                          return 'WIDTH';
"min-width"                       return 'MIN_WIDTH';
"max-width"                       return 'MAX_WIDTH';
"min-height"                      return 'MIN_HEIGHT';
"max-height"                      return 'MAX_HEIGHT';
"background color"                return 'BACKGROUND_COLOR';
"color"                           return 'COLOR';
"text align"                      return 'TEXT_ALIGN';
"text size"                       return 'TEXT_SIZE';
"text font"                       return 'TEXT_FONT';
"padding"                         return 'PADDING';
"margin"                          return 'MARGIN';
"border"                          return 'BORDER';
"left"                            return 'LEFT';
"top"                             return 'TOP';
"right"                           return 'RIGHT';
"bottom"                          return 'BOTTOM';
"style"                           return 'STYLE';
"radius"                          return 'RADIUS';
"extends"                         return 'EXTENDS';

"CENTER"    return 'CENTER_D';
"RIGHT"     return 'RIGHT_D';
"LEFT"      return 'LEFT_D';

"@for"      return 'FOR';
"$i"        return 'INDEX';
"from"      return 'FROM';
"through"   return 'THROUGH';
"to"        return 'TO';

"HELVETICA"   return 'HELVETICA';
"SANS SERIF"  return 'SANS_SERIF';
"SANS"        return 'SANS';
"MONO"        return 'MONO';
"CURSIVE"     return 'CURSIVE';

"+"   return 'MAS';
"-"   return 'MENOS';
"*"   return 'POR';
"/"   return 'ENTRE';
"("   return 'PAREN_IZQ';
")"   return 'PAREN_DER';

"DOTTED"  return 'DOTTED';
"LINE"    return 'LINE';
"DOUBLE"  return 'DOUBLE';
"solid"   return 'SOLID';

"{"   return 'LLAVE_APERTURA';
"}"   return 'LLAVE_CIERRE';
";"   return 'PUNTO_Y_COMA';
"="   return 'IGUAL';

rgb\(\s*[0-9]{1,3}\s*\,\s*[0-9]{1,3}\s*\,\s*[0-9]{1,3}\s*\)  return 'RGB';
"#"[0-9a-fA-F]{6}   return 'HEX';
"blue"      return 'BLUE';
"white"     return 'WHITE';
"red"       return 'RED';
"green"     return 'GREEN';
"violet"    return 'VIOLET';
"gray"      return 'GRAY';
"black"     return 'BLACK';
"lightgray" return 'LIGHTGRAY';

[0-9]+(\.[0-9]+)?"%"   return 'PORCENTAJE';
[0-9]+(\.[0-9]+)?      return 'NUMERO';
"%"                    return 'MODULO';
[a-zA-Z0-9_-]+         return 'IDENTIFICADOR';

<<EOF>>   return 'EOF';
.         return 'INVALID';

/lex

%{
%}

%start s

%token HEIGHT WIDTH MIN_WIDTH MAX_WIDTH MIN_HEIGHT MAX_HEIGHT
%token BACKGROUND_COLOR COLOR TEXT_ALIGN TEXT_SIZE TEXT_FONT
%token PADDING MARGIN BORDER LEFT TOP RIGHT BOTTOM STYLE RADIUS
%token EXTENDS CENTER_D RIGHT_D LEFT_D
%token FOR INDEX FROM THROUGH TO
%token HELVETICA SANS SANS_SERIF MONO CURSIVE
%token MAS MENOS POR ENTRE MODULO PAREN_IZQ PAREN_DER
%token DOTTED LINE DOUBLE SOLID
%token LLAVE_APERTURA LLAVE_CIERRE PUNTO_Y_COMA IGUAL
%token RGB HEX BLUE WHITE RED GREEN VIOLET GRAY BLACK LIGHTGRAY
%token IDENTIFICADOR NUMERO PORCENTAJE EOF INVALID

%left MAS MENOS
%left POR ENTRE MODULO
%right UMINUS

%%

s
  : programa EOF
      { return $1; }
  ;

programa
  : elementos
      { $$ = { tipo: 'Programa', elementos: $1 }; }
  ;

elementos
  : elementos elemento
      { $$ = $1.concat([$2]); }
  | elemento
      { $$ = [$1]; }
  ;

elemento
  : estilo  { $$ = $1; }
  | ciclo   { $$ = $1; }
  ;

ciclo
  : FOR INDEX FROM NUMERO TO NUMERO LLAVE_APERTURA estilos LLAVE_CIERRE
      { $$ = { tipo: 'Ciclo', modo: 'to', desde: Number($4), hasta: Number($6), cuerpo: $8 }; }
  | FOR INDEX FROM NUMERO THROUGH NUMERO LLAVE_APERTURA estilos LLAVE_CIERRE
      { $$ = { tipo: 'Ciclo', modo: 'through', desde: Number($4), hasta: Number($6), cuerpo: $8 }; }
  ;

estilos
  : estilos estilo
      { $$ = $1.concat([$2]); }
  | estilo
      { $$ = [$1]; }
  ;

estilo
  : clase LLAVE_APERTURA atributos LLAVE_CIERRE
      { $$ = { tipo: 'Estilo', clase: $1, atributos: $3 }; }
  ;

clase
  : nombre_clase
      { $$ = { nombre: $1, extiende: null }; }
  | nombre_clase EXTENDS nombre_clase
      { $$ = { nombre: $1, extiende: $3 }; }
  ;

palabra
  : IDENTIFICADOR    { $$ = $1; }
  | PADDING          { $$ = 'padding'; }
  | MARGIN           { $$ = 'margin'; }
  | BORDER           { $$ = 'border'; }
  | HEIGHT           { $$ = 'height'; }
  | WIDTH            { $$ = 'width'; }
  | MIN_WIDTH        { $$ = 'min-width'; }
  | MAX_WIDTH        { $$ = 'max-width'; }
  | MIN_HEIGHT       { $$ = 'min-height'; }
  | MAX_HEIGHT       { $$ = 'max-height'; }
  | COLOR            { $$ = 'color'; }
  | TOP              { $$ = 'top'; }
  | BOTTOM           { $$ = 'bottom'; }
  | LEFT             { $$ = 'left'; }
  | RIGHT            { $$ = 'right'; }
  | STYLE            { $$ = 'style'; }
  | RADIUS           { $$ = 'radius'; }
  | FROM             { $$ = 'from'; }
  | TO               { $$ = 'to'; }
  | THROUGH          { $$ = 'through'; }
  | BACKGROUND_COLOR { $$ = 'background-color'; }
  | TEXT_ALIGN       { $$ = 'text-align'; }
  | TEXT_SIZE        { $$ = 'text-size'; }
  | TEXT_FONT        { $$ = 'text-font'; }
  | DOTTED           { $$ = 'DOTTED'; }
  | LINE             { $$ = 'LINE'; }
  | DOUBLE           { $$ = 'DOUBLE'; }
  | SOLID            { $$ = 'solid'; }
  | HELVETICA        { $$ = 'HELVETICA'; }
  | SANS             { $$ = 'SANS'; }
  | MONO             { $$ = 'MONO'; }
  | CURSIVE          { $$ = 'CURSIVE'; }
  | MENOS            { $$ = '-'; }
  ;

nombre_clase
  : nombre_clase palabra
      { $$ = $1 + $2; }
  | nombre_clase INDEX
      { $$ = $1 + '$i'; }
  | palabra
      { $$ = $1; }
  | INDEX
      { $$ = '$i'; }
  ;

atributos
  : atributos atributo
      { $$ = $1.concat([$2]); }
  |
      { $$ = []; }
  ;

atributo
  : clave IGUAL expresion PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: $1, valor: $3 }; }
  | clave IGUAL PORCENTAJE PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: $1, valor: { tipo: 'Porcentaje', valor: $3 } }; }
  | BACKGROUND_COLOR IGUAL color PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: 'background-color', valor: $3 }; }
  | COLOR IGUAL color PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: 'color', valor: $3 }; }
  | TEXT_ALIGN IGUAL alineacion PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: 'text-align', valor: $3 }; }
  | TEXT_FONT IGUAL fuente PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: 'text-font', valor: $3 }; }
  | borde IGUAL valor_borde PUNTO_Y_COMA
      { $$ = { tipo: 'Atributo', propiedad: $1, valor: $3 }; }
  ;

clave
  : HEIGHT      { $$ = 'height'; }
  | WIDTH       { $$ = 'width'; }
  | MIN_WIDTH   { $$ = 'min-width'; }
  | MAX_WIDTH   { $$ = 'max-width'; }
  | MIN_HEIGHT  { $$ = 'min-height'; }
  | MAX_HEIGHT  { $$ = 'max-height'; }
  | TEXT_SIZE   { $$ = 'text-size'; }
  | padding     { $$ = $1; }
  | margin      { $$ = $1; }
  ;

direccion
  : TOP     { $$ = 'top'; }
  | BOTTOM  { $$ = 'bottom'; }
  | LEFT    { $$ = 'left'; }
  | RIGHT   { $$ = 'right'; }
  ;

estilo_borde
  : RADIUS  { $$ = 'radius'; }
  | STYLE   { $$ = 'style'; }
  | WIDTH   { $$ = 'width'; }
  | COLOR   { $$ = 'color'; }
  ;

borde
  : BORDER
      { $$ = 'border'; }
  | BORDER estilo_borde
      { $$ = 'border-' + $2; }
  | BORDER direccion
      { $$ = 'border-' + $2; }
  | BORDER direccion estilo_borde
      { $$ = 'border-' + $2 + '-' + $3; }
  ;

valor_borde
  : lista_borde
      { $$ = { tipo: 'ValorBorde', partes: $1 }; }
  ;

lista_borde
  : lista_borde item_borde
      { $$ = $1.concat([$2]); }
  | item_borde
      { $$ = [$1]; }
  ;

item_borde
  : NUMERO
      { $$ = { tipo: 'Numero', valor: Number($1) }; }
  | INDEX
      { $$ = { tipo: 'Indice', valor: '$i' }; }
  | tipo_borde
      { $$ = { tipo: 'TipoBorde', valor: $1 }; }
  | color
      { $$ = $1; }
  ;

padding
  : PADDING
      { $$ = 'padding'; }
  | PADDING direccion
      { $$ = 'padding-' + $2; }
  ;

margin
  : MARGIN
      { $$ = 'margin'; }
  | MARGIN direccion
      { $$ = 'margin-' + $2; }
  ;

expresion
  : expresion MAS termino
      { $$ = { tipo: 'Operacion', op: '+', izq: $1, der: $3 }; }
  | expresion MENOS termino
      { $$ = { tipo: 'Operacion', op: '-', izq: $1, der: $3 }; }
  | termino
      { $$ = $1; }
  ;

termino
  : termino POR factor
      { $$ = { tipo: 'Operacion', op: '*', izq: $1, der: $3 }; }
  | termino ENTRE factor
      { $$ = { tipo: 'Operacion', op: '/', izq: $1, der: $3 }; }
  | termino MODULO factor
      { $$ = { tipo: 'Operacion', op: '%', izq: $1, der: $3 }; }
  | factor
      { $$ = $1; }
  ;

factor
  : MENOS factor %prec UMINUS
      { $$ = { tipo: 'Negativo', valor: $2 }; }
  | MAS factor
      { $$ = $2; }
  | PAREN_IZQ expresion PAREN_DER
      { $$ = $2; }
  | NUMERO
      { $$ = { tipo: 'Numero', valor: Number($1) }; }
  | IDENTIFICADOR
      { $$ = { tipo: 'Identificador', valor: $1 }; }
  | INDEX
      { $$ = { tipo: 'Indice', valor: '$i' }; }
  ;

color
  : RGB         { $$ = { tipo: 'Color', formato: 'rgb',    valor: $1 }; }
  | HEX         { $$ = { tipo: 'Color', formato: 'hex',    valor: $1 }; }
  | BLUE        { $$ = { tipo: 'Color', formato: 'nombre', valor: 'blue' }; }
  | WHITE       { $$ = { tipo: 'Color', formato: 'nombre', valor: 'white' }; }
  | RED         { $$ = { tipo: 'Color', formato: 'nombre', valor: 'red' }; }
  | GREEN       { $$ = { tipo: 'Color', formato: 'nombre', valor: 'green' }; }
  | VIOLET      { $$ = { tipo: 'Color', formato: 'nombre', valor: 'violet' }; }
  | GRAY        { $$ = { tipo: 'Color', formato: 'nombre', valor: 'gray' }; }
  | BLACK       { $$ = { tipo: 'Color', formato: 'nombre', valor: 'black' }; }
  | LIGHTGRAY   { $$ = { tipo: 'Color', formato: 'nombre', valor: 'lightgray' }; }
  ;

tipo_borde
  : DOTTED  { $$ = 'DOTTED'; }
  | LINE    { $$ = 'LINE'; }
  | DOUBLE  { $$ = 'DOUBLE'; }
  | SOLID   { $$ = 'solid'; }
  ;

alineacion
  : CENTER_D  { $$ = 'CENTER'; }
  | RIGHT_D   { $$ = 'RIGHT'; }
  | LEFT_D    { $$ = 'LEFT'; }
  ;

fuente
  : HELVETICA   { $$ = 'HELVETICA'; }
  | SANS        { $$ = 'SANS'; }
  | SANS_SERIF  { $$ = 'SANS_SERIF'; }
  | MONO        { $$ = 'MONO'; }
  | CURSIVE     { $$ = 'CURSIVE'; }
  ;
