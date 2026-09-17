const express = require('express');
const app     = express();

require('dotenv').config({ path: './.env' });

// ─── CORS ─────────────────────────────────────────────────────────────────────
// Autorise Flutter Web (localhost) + mobile + production
app.use(require('cors')({
    origin: '*', // En production : remplacez par votre domaine ex: 'https://monapp.com'
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Répond aux preflight OPTIONS (nécessaire pour Flutter Web + multipart)
app.options('*', require('cors')());

// ─── Body parsers ─────────────────────────────────────────────────────────────
app.use(require('body-parser').json({ limit: '10000mb' }));
app.use(require('body-parser').urlencoded({ extended: true, limit: '10000mb' }));

// ─── Fichiers statiques ───────────────────────────────────────────────────────
app.use('/yaatal-file', require('express').static('uploads'));

// ─── Routes existantes ────────────────────────────────────────────────────────
app.use('/api/v1/users', require('./routes/user-routes'));
app.use('/api/v1/files', require('./routes/file'));

// ─── Nouvelle route candidatures (formulaire Flutter) ─────────────────────────
app.use('/api/v1/candidatures', require('./routes/candidature-routes'));

// ─── Route de test ────────────────────────────────────────────────────────────
app.get('/api/v1/ping', (req, res) => {
    res.json({ status: 'OK', message: 'Serveur opérationnel' });
});

// ─── Démarrage ────────────────────────────────────────────────────────────────
require('./configs/db')().then(_ => {
    const port = process.env.PORT || 4000;
    app.listen(port, () => {
        console.log(process.env.MONGODB_URI);
        console.log(`✅ Server started on port ${port}`);
        console.log(`   Ping : http://localhost:${port}/api/v1/ping`);
    });
});