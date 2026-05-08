const parser = require('./bd.js');
const fs = require('fs');
const path = require('path');
const archivo = process.argv[2];
if (!archivo) { console.error('Uso: node parser_db.js <archivo>'); process.exit(1); }
const fuente = fs.readFileSync(path.resolve(archivo), 'utf8');
try {
    const ast = parser.parse(fuente);
    console.log(JSON.stringify(ast, null, 2));
} catch(e) {
    console.error('Error fatal:', e.message);
    process.exit(1);
}
