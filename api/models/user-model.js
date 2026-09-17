const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const UsersModels = new Schema({
    service: {
        type: String,
        enum: ["admin", "super"],
        default: "admin"
    },
    nom: {
        type: String,
        trim: true
    },
    prenom: {
        type: String,
        trim: true
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
        validate: {
            validator: function(v) {
                return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
            },
            message: props => `${props.value} n'est pas un email valide!`
        }
    },
    password: {
        type: String,
        required: true,
        minlength: 6
    },
    statusConexion: {
        type: String,
        default: "inactive"
    },
    statusOnline: {
        type: String,
        enum: ["on", "off", "del"],
        default: "on"
    },
    token: {
        type: String
    },
    derniereConnexion: {
        type: Date
    }
}, {
    toJSON: {
        transform: function (doc, ret) {
            ret.id = ret._id;
            delete ret._id;
            delete ret.password;
            delete ret.statusConexion;
            delete ret.__v;
        },
    },
    timestamps: true
});

// Index
// UsersModels.index({ email: 1 });
UsersModels.index({ service: 1 });
UsersModels.index({ statusOnline: 1 });

module.exports = mongoose.model('user-admin', UsersModels);
