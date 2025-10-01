const mysql = require("mysql2")
const dotenv = require("dotenv");


dotenv.config();

const conection = mysql.createConnection({
host: DB_HOST,
user: BD_USER,
password: BD_PASSWORD,
database: DB_DATABASE,
port: DB_PORT
});


module.exports = {conection}