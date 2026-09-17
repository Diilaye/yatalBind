const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const ConcurrentModel = new Schema({
    sexe: {
        type: String,
        enum: ["masculin", "feminin"],
        default: "masculin"
    },
    nom: {
        type: String,
        required: true,
        trim: true,
        maxlength: [100, 'Le nom ne peut pas dépasser 100 caractères']
    },
    prenom: {
        type: String,
        required: true,
        trim: true,
        maxlength: [100, 'Le prénom ne peut pas dépasser 100 caractères']
    },
    daara: {
        type: String,
        default: "",
        trim: true,
        maxlength: [200, "Le nom de l'école ne peut pas dépasser 200 caractères"]
    },
    adresse: {
        type: String,
        default: "",
        trim: true,
        maxlength: [300, "L'adresse ne peut pas dépasser 300 caractères"]
    },
    telephone: {
        type: String,
        required: true,
        unique: true,
        validate: {
            validator: function (v) {
                return /^(77|78|75|76|70)\d{7}$/.test(v);
            },
            message: props => `${props.value} n'est pas un numéro de téléphone valide!`
        }
    },
    age: {
        type: Number,
        min: 5,
        max: 120
    },
    dateNaissance: {
        type: Date
    },
    niveauEtudes: {
        type: String,
        enum: ["primaire", "moyen", "secondaire", "superieur", "autre"],
        default: "primaire"
    },

    // ─── Champs ajoutés pour le formulaire Flutter ───────────────────────────

    professeur: {
        type: String,
        default: "",
        trim: true,
        maxlength: [150, 'Le nom du professeur ne peut pas dépasser 150 caractères']
    },

    fichierJustificatif: {
        url: {
            type: String,
            default: null
        },
        nomFichier: {
            type: String,
            default: null
        },
        typeFichier: {
            type: String,
            enum: ["pdf", "doc", "docx", "jpg", "jpeg", "png", "webp", null],
            default: null
        },
        tailleFichier: {
            type: Number, // en bytes
            default: null
        }
    },

    // Source d'inscription : 'csv' (import admin) ou 'formulaire' (Flutter)
    sourceInscription: {
        type: String,
        enum: ["csv", "formulaire"],
        default: "formulaire"
    },

    fichierSource: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'media'
    }

}, {
    toJSON: {
        transform: function (doc, ret) {
            ret.id = ret._id;
            delete ret._id;
            delete ret.__v;
        },
    },
    timestamps: true
});

ConcurrentModel.index({ telephone: 1 });
ConcurrentModel.index({ nom: 1, prenom: 1 });
ConcurrentModel.index({ daara: 1 });
ConcurrentModel.index({ createdAt: -1 });

module.exports = mongoose.model('concurrent', ConcurrentModel);