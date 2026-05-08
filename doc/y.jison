%lex
%%

\s+                              /* ignorar espacios */
\/\*[\s\S]*?\*\/                 /* comentario de bloque */

"int"   return 'INT';
"float" return 'FLOAT';
"string"    return 'STRING';
"boolean"   return 'BOOLEAN';
"char"  return 'CHAR';
