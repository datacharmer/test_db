const express = require('express');
const app = express();
const port = process.env.PORT || 4001;
const employees = require ('./routes/employees.js');
const salaries = require ('./routes/salaries.js');
const departments = require ('./routes/departments.js');


app.get('/', (req, res) => {
    res.send('Welcome to our API!')
  })

  app.use(employees);
  app.use(salaries);
  app.use(departments);
  
app.listen(port, () => {
   console.log(`Web server is listening on port ${port}!`);
  });