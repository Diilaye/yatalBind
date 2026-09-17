const path = require('path');
const fs = require('fs');
const multer = require('multer');
const coucurantModel = require('../models/concurant-model');

// ─── Types de fichiers autorisés ─────────────────────────────────────────────
const ALLOWED_MIME_TYPES = [
    'application/pdf',
    'application/msword',                                                          // .doc
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',    // .docx
    'image/jpeg',
    'image/png',
    'image/webp',
];

const ALLOWED_EXTENSIONS = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'webp'];

const MAX_FILE_SIZE = 2 * 1024 * 1024; // 2 Mo

// ─── Configuration Multer ─────────────────────────────────────────────────────
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const dir = path.join(__dirname, '..', 'uploads', 'justificatifs');
        if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        // Nom sécurisé : timestamp + extension uniquement (pas de nom user)
        const ext = path.extname(file.originalname).toLowerCase().replace('.', '');
        cb(null, `justif_${Date.now()}_${Math.random().toString(36).slice(2)}.${ext}`);
    }
});

const fileFilter = (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase().replace('.', '');

    if (!ALLOWED_MIME_TYPES.includes(file.mimetype) || !ALLOWED_EXTENSIONS.includes(ext)) {
        return cb(new Error(`Type de fichier non autorisé: ${file.mimetype}`), false);
    }
    cb(null, true);
};

const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: MAX_FILE_SIZE }
}).single('fichierJustificatif');

// ─── Sanitisation : supprime tout caractère dangereux ────────────────────────
function sanitizeString(value) {
    if (typeof value !== 'string') return '';
    // Supprime balises HTML, opérateurs NoSQL MongoDB ($, .)
    return value
        .replace(/<[^>]*>/g, '')           // balises HTML
        .replace(/[<>"'`;\\]/g, '')        // caractères spéciaux dangereux
        .replace(/\$|\{|\}/g, '')          // opérateurs NoSQL ($, {, })
        .trim()
        .slice(0, 300);                    // limite absolue de longueur
}

function sanitizePhone(value) {
    if (typeof value !== 'string') return '';
    return value.replace(/[^0-9]/g, '').slice(0, 15);
}

// ─── Validation métier ────────────────────────────────────────────────────────
function validateAge(dateNaissance) {
    const birth = new Date(dateNaissance);
    if (isNaN(birth.getTime())) return false;
    const age = new Date().getFullYear() - birth.getFullYear();
    return age <= 40 && age >= 10;
}

function validatePhone(phone) {
    return /^(77|78|75|76|70)\d{7}$/.test(phone);
}

// ─── Controller principal ─────────────────────────────────────────────────────

/**
 * POST /api/v1/candidatures/inscrire
 * multipart/form-data
 * Champs : prenom, nom, telephone, dateNaissance, adresse, ecole, professeur, sexe (optionnel)
 * Fichier : fichierJustificatif (pdf | doc | docx | jpg | jpeg | png | webp)
 */
exports.inscrire = (req, res) => {
    upload(req, res, async (err) => {

        // ── Erreurs Multer ──────────────────────────────────────────────────
        if (err instanceof multer.MulterError) {
            if (err.code === 'LIMIT_FILE_SIZE') {
                return res.status(400).json({
                    message: 'Le fichier ne doit pas dépasser 2 Mo.',
                    status: 'NOT OK',
                    statusCode: 400
                });
            }
            return res.status(400).json({
                message: `Erreur upload: ${err.message}`,
                status: 'NOT OK',
                statusCode: 400
            });
        }

        if (err) {
            return res.status(400).json({
                message: err.message,
                status: 'NOT OK',
                statusCode: 400
            });
        }

        try {
            // ── Sanitisation des champs texte ───────────────────────────────
            const prenom        = sanitizeString(req.body.prenom);
            const nom           = sanitizeString(req.body.nom);
            const telephone     = sanitizePhone(req.body.telephone);
            const dateNaissance = sanitizeString(req.body.dateNaissance);
            const adresse       = sanitizeString(req.body.adresse);
            const ecole         = sanitizeString(req.body.ecole);
            const professeur    = sanitizeString(req.body.professeur);
            const sexe          = ['masculin', 'feminin'].includes(req.body.sexe)
                                    ? req.body.sexe
                                    : 'masculin';

            // ── Validation des champs obligatoires ──────────────────────────
            const errors = [];

            if (!prenom)        errors.push('Le prénom est obligatoire.');
            if (!nom)           errors.push('Le nom est obligatoire.');
            if (!telephone)     errors.push('Le téléphone est obligatoire.');
            if (!dateNaissance) errors.push('La date de naissance est obligatoire.');
            if (!adresse)       errors.push('L\'adresse est obligatoire.');
            if (!ecole)         errors.push('L\'école est obligatoire.');
            if (!professeur)    errors.push('Le professeur est obligatoire.');

            if (!validatePhone(telephone)) {
                errors.push('Numéro de téléphone invalide (doit commencer par 77, 78, 75, 76 ou 70).');
            }

            if (dateNaissance && !validateAge(dateNaissance)) {
                errors.push('L\'âge du candidat doit être inférieur ou égal à 34 ans.');
            }

            if (!req.file) {
                errors.push('Le document justificatif est obligatoire.');
            }

            if (errors.length > 0) {
                // Supprimer le fichier uploadé si validation échoue
                if (req.file) fs.unlinkSync(req.file.path);
                return res.status(422).json({
                    message: 'Données invalides.',
                    errors,
                    status: 'NOT OK',
                    statusCode: 422
                });
            }

            // ── Vérification doublon téléphone ──────────────────────────────
            const existant = await coucurantModel.findOne({ telephone }).exec();
            if (existant) {
                if (req.file) fs.unlinkSync(req.file.path);
                return res.status(409).json({
                    message: 'Un candidat avec ce numéro de téléphone existe déjà.',
                    status: 'NOT OK',
                    statusCode: 409
                });
            }

            // ── Construction du document ────────────────────────────────────
            const ext = path.extname(req.file.originalname).toLowerCase().replace('.', '');

            const concurrent = coucurantModel();
            concurrent.prenom           = prenom;
            concurrent.nom              = nom;
            concurrent.telephone        = telephone;
            concurrent.dateNaissance    = new Date(dateNaissance);
            concurrent.age              = new Date().getFullYear() - new Date(dateNaissance).getFullYear();
            concurrent.adresse          = adresse;
            concurrent.daara            = ecole;
            concurrent.professeur       = professeur;
            concurrent.sexe             = sexe;
            concurrent.sourceInscription = 'formulaire';

            concurrent.fichierJustificatif = {
                url:          `justificatifs/${req.file.filename}`,
                nomFichier:   req.file.filename,
                typeFichier:  ext,
                tailleFichier: req.file.size
            };

            const saved = await concurrent.save();

            return res.status(201).json({
                message: 'Inscription enregistrée avec succès.',
                status: 'OK',
                data: saved,
                statusCode: 201
            });

        } catch (error) {
            if (req.file) fs.unlinkSync(req.file.path);

            // Erreur de validation Mongoose
            if (error.name === 'ValidationError') {
                const msgs = Object.values(error.errors).map(e => e.message);
                return res.status(422).json({
                    message: 'Erreur de validation.',
                    errors: msgs,
                    status: 'NOT OK',
                    statusCode: 422
                });
            }

            // Doublon (code MongoDB 11000)
            if (error.code === 11000) {
                return res.status(409).json({
                    message: 'Un candidat avec ce numéro de téléphone existe déjà.',
                    status: 'NOT OK',
                    statusCode: 409
                });
            }

            console.error('Erreur inscription:', error);
            return res.status(500).json({
                message: 'Erreur serveur.',
                status: 'NOT OK',
                statusCode: 500
            });
        }
    });
};