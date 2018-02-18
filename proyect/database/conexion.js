'use strict';
const mongoose = require('mongoose');
var Config = require("../config");
function conectar(callback) {
	var uri = 'mongodb://'+Config.IP_DATABASE+':27017/cms';
	mongoose.Promise = global.Promise;
	mongoose.connect(uri, { useMongoClient: true })
    .then((resp) =>{/*console.log("Conectado a la base de datos!");*/callback(resp);})
    .catch(err => {console.log(err);callback(null)});	
}

function cerrar() {
	mongoose.connection.close(function(err,res){
		//console.log("Desconectado de la base de datos");
	})
}

// con esta funcion obtenemos la ip de nuestro nodo worker
function getIPAddress() {
	var interfaces = require('os').networkInterfaces();
	for (var devName in interfaces) {
	  var iface = interfaces[devName];
  
	  for (var i = 0; i < iface.length; i++) {
		var alias = iface[i];
		if (alias.family === 'IPv4' && alias.address !== '127.0.0.1' && !alias.internal)
		  return alias.address;
	  }
	}
  
	return '0.0.0.0';
}

module.exports={
    conectar,
    cerrar
}
