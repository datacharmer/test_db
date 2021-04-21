const express = require('express');
const router = express.Router()
const controllers = require('../controllers/salaries.js')


router.get('/', controllers.getSalaries);

router.get('/:emp_no', controllers.getSalariesByHistory);

router.get('/name/:dept_name', controllers.getSalariesByName);


module.exports = router