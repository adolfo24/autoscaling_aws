'use strict'
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const UserSchema=Schema({
    name:{ type :String,required:true},//nombre de usuario
    email:{ type :String,required:true},//email de usuario
    date:{type:Date,default:Date.now},//fecha de registro de usuario
    isDelete:{type:Boolean,default:false}//BORRADO O NO
});

module.exports=mongoose.model('User',UserSchema);