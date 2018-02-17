'use strict'
var User = require('../model/user');
var conexion = require('../database/conexion')
function getUsers(datos,callback){
    conexion.conectar(function(conex){
        if(conex!=null){
            User.find({},(err,stores)=>{
                if(err){
                    conexion.cerrar();
                    callback({success:false,message:"Error al obtener los datos         [INFO]"});
                }else{
                    conexion.cerrar();
                    callback({success:true,message:"Exito",datos:stores});        
                }
            })
        }else{
            conexion.cerrar();
            callback({success:false,message:"error de conexion a db                  [ERROR]"});
        }
    })
}
function addUser(datos,callback){
    conexion.conectar(function(conex){
        if(conex!=null){
            var user = new User(datos.body);
            user.save((err,store)=>{
                if(err){
                    conexion.cerrar();
                    callback({success:false,message:"Error guardar         [ERROR]"});
                }else{
                    conexion.cerrar();
                    callback({success:true,message:"Exito",datos:store});        
                }
            })
        }else{
            conexion.cerrar();
            callback({success:false,message:"error de conexion a db                  [ERROR]"});
        }
    })
}

module.exports={
    getUsers,
    addUser
}