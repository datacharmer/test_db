const express = require('express');
const router = express.Router()
const controllers = require('../controllers/employees.js')


router.get('/', controllers.getEmployees);

router.get('/:id', controllers.getEmployeesById);

router.get('/firstname/:first_name', controllers.getEmployeesByFirstName);


module.exports = router