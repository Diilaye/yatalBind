const mongoose = require('mongoose');

const Schema = mongoose.Schema;

const MessageModel = new Schema({
    titre: {
        type: String,
        required: true,
        trim: true
    },
    subTitle: {
        type: String,
        trim: true
    },
    desc: {
        type: String,
        trim: true
    },
    sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'concurrent',
        required: true
    },
    success: {
        type: String,
        enum: ["0", "1"],
        default: "0"
    },
    dateEnvoi: {
        type: Date,
        default: Date.now
    },
    statutLecture: {
        type: String,
        enum: ["non_lu", "lu", "archive"],
        default: "non_lu"
    },
    dateLecture: {
        type: Date
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
MessageModel.index({ sender: 1 });
MessageModel.index({ success: 1 });
MessageModel.index({ statutLecture: 1 });
MessageModel.index({ dateEnvoi: -1 });
MessageModel.index({ createdAt: -1 });

module.exports = mongoose.model('messages', MessageModel);
