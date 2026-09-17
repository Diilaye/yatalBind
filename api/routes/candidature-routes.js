const express = require('express');
const router = express.Router();
const candidatureController = require('../controllers/candidature-controller');

// POST /api/v1/candidatures/inscrire
// multipart/form-data (fichier + champs texte)
router.post('/inscrire', candidatureController.inscrire);

module.exports = router;