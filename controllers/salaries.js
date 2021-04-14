const mysql = require("mysql");
const pool = require("../mysql/connection.js");

const getSalaries = (req, res) => {
    let sql = "SELECT * FROM salaries LIMIT 50";

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}


const getSalariesByHistory = (req, res) => {

    let sql = "SELECT * FROM salaries WHERE emp_no = ?";

    const replacements = [req.params.emp_no];

    sql = mysql.format(sql, replacements);

    pool.query(sql, (err, results) =>{
        if (err){
            return res.status(500).send("something went wrong")
        } else {
            return res.json(results);
        }
    })
}


const getSalariesByName = (req, res) => {

    let sql = "SELECT * FROM salaries WHERE first_name = ?";

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

module.exports = { getSalaries, getSalariesByHistory, getSalariesByName };