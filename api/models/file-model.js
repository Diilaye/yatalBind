const mongoose = require('mongoose');

const Schema = mongoose.Schema;
const FileModel = new Schema({
    url: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: ["csv", "xlsx", "pdf", "video", "autre"],
        default: "xlsx"
    },
    nomFichier: {
        type: String,
        required: true
    },
    tailleFichier: {
        type: Number // en bytes
    },
    statut: {
        type: String,
        enum: ["en_attente", "traite", "erreur"],
        default: "en_attente"
    },
    nombreConcurrents: {
        type: Number,
        default: 0
    },
    uploadePar: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user-admin'
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

// Index
FileModel.index({ type: 1 });
FileModel.index({ statut: 1 });
FileModel.index({ createdAt: -1 });

module.exports = mongoose.model('media', FileModel);

