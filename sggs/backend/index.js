const express = require('express');
const app = express();
const mysql = require('mysql2');
const cors = require('cors');

// Habilitamos CORS para permitir solicitudes desde el cliente
app.use(cors());

// Middleware para poder leer JSON del body
app.use(express.json());

// Creamos la conexión a la base de datos
const db = mysql.createConnection({
    host: "127.0.0.1",
    user: "root",
    password: "ndt782a2",
    database: "empleados_crud"
});