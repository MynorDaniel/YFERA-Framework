const parser = require('./styles.js');
const fs     = require('fs');
const path   = require('path');

const archivo = process.argv[2];
if (!archivo) {
    console.error('Uso: node test.js <archivo.styles>');
    process.exit(1);
}

const fuente = fs.readFileSync(path.resolve(archivo), 'utf8');

try {
    const ast = parser.parse(fuente);
    console.log(JSON.stringify(ast, null, 2));
} catch (e) {
    console.error(e.message);
    process.exit(1);
}
