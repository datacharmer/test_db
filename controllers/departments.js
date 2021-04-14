const mysql = require("mysql");
const pool = require("../mysql/connection.js");

const getDepartments = (req, res) => {
    let sql = "SELECT * FROM departments LIMIT 50";

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}


const getDepartmentsById = (req, res) => {

    let sql = "SELECT * FROM departments WHERE dept_no = ?";

    const replacements = [req.params.dept_no];

    sql = mysql.format(sql, replacements);

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}


const getDepartmentsByName = (req, res) => {

    let sql = "SELECT * FROM departments WHERE first_name = ?";

    const replacements = [req.params.dept_name];

    sql = mysql.format(sql, replacements);

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}

module.exports = { getDepartments, getDepartmentsById, getDepartmentsByName };