const mysql = require("mysql");
const pool = require("../mysql/connection.js");

const getEmployees = (req, res) => {
    let sql = "SELECT * FROM employees LIMIT 50";

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}


const getEmployeesById = (req, res) => {

    let sql = "SELECT * FROM employees WHERE emp_no = ?";

    const replacements = [req.params.id];

    sql = mysql.format(sql, replacements);

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}


const getEmployeesByFirstName = (req, res) => {

    let sql = "SELECT * FROM employees WHERE first_name = ?";

    const replacements = [req.params.first_name];

    sql = mysql.format(sql, replacements);

    pool.query("SELECT * FROM employees", (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}

module.exports = { getEmployees, getEmployeesById, getEmployeesByFirstName }