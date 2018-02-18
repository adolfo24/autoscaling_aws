var express = require('express');
var router = express.Router();
var User = require('../controller/user');
/* GET users listing. */
router.get('/', function(req, res) {
  User.getUsers(req,(resp)=>{
    res.render('users', { title: 'User',datos:resp.datos});
  }) 
});
router.get('/new', function(req, res) {
  res.render('userNew', { title: 'New User'}); 
});
router.post('/register', function(req, res) {
  User.addUser(req,(resp)=>{
    User.getUsers(req,(resp)=>{
      res.render('users', { title: 'User',datos:resp.datos});
    })
  })
});

module.exports = router;
