const express = require('express');
const router = express.Router()
const controllers = require('../controllers/departments.js')


router.get('/', controllers.getDepartments);

router.get('/:dept_no', controllers.getDepartmentsById);

router.get('/name/:dept_name', controllers.getDepartmentsByName);


module.exports = router