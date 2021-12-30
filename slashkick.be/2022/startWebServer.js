var express = require('express');
var app = express();

app.get(/^(.+)$/, (req, res) => {
    let path = req.params[0].replace(/\//g, '\\');
    if (path.startsWith('\\')) {
        path = path.slice(1);
    }
    console.log(`${path}`);
    if (!path || path === '/') {
        path = 'index.html';
    }
    res.sendFile(`${__dirname}\\www\\${path}`);
});

const port = 1222;

app.listen(port, null, () => {
    console.log(`http://localhost:${port}`);
});


