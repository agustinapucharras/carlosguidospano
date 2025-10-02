-- =============================================
-- SISTEMA DE GESTIÓN EDUCATIVA - MySQL
-- Base de datos completa y corregida
-- =============================================

-- Eliminar base de datos existente si es necesario
-- DROP DATABASE IF EXISTS SGGS;
CREATE DATABASE SGGS;
USE SGGS;

-- =============================================
-- TABLAS PRINCIPALES
-- =============================================

-- Tabla de usuarios del sistema
CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_usuario VARCHAR(100) UNIQUE NOT NULL,
    rol ENUM('admin', 'docente', 'preceptor', 'secretario', 'tutor') NOT NULL,
    estado ENUM('activo', 'inactivo', 'pendiente') DEFAULT 'activo',
    ultimo_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabla de años lectivos
CREATE TABLE anio_lectivo (
    id_anio_lectivo INT PRIMARY KEY AUTO_INCREMENT,
    anio INT UNIQUE NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('planificacion', 'activo', 'finalizado') DEFAULT 'planificacion',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de tutores (padres/madres/adultos responsables)
CREATE TABLE tutor (
    id_tutor INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NULL,
    dni_tutor VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion VARCHAR(150),
    parentesco ENUM('padre', 'madre', 'tutor legal', 'abuelo/a', 'otro') NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
);

-- Tabla de docentes (profesores)
CREATE TABLE docente (
    id_docente INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NULL,
    dni_docente VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(20),
    especialidad VARCHAR(100),
    estado ENUM('activo', 'licencia', 'inactivo') DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
);

-- Tabla de cursos
CREATE TABLE curso (
    id_curso INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    anio INT NOT NULL, -- 1°, 2°, 3° año, etc.
    division VARCHAR(10) NOT NULL, -- "A", "B", "C"
    turno ENUM('mañana', 'tarde', 'noche') NOT NULL,
    id_docente_tutor INT NULL,
    estado ENUM('activo', 'inactivo', 'completado') DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_docente_tutor) REFERENCES docente(id_docente) ON DELETE SET NULL
);

-- Tabla de materias (asignaturas)
CREATE TABLE materia (
    id_materia INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    carga_horaria INT,
    nivel INT NOT NULL, -- 1, 2, 3 (corresponde con año)
    ciclo ENUM('basico', 'superior') DEFAULT 'basico',
    estado ENUM('activa', 'inactiva') DEFAULT 'activa',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Tabla de alumnos
CREATE TABLE alumno (
    id_alumno INT PRIMARY KEY AUTO_INCREMENT,
    dni_alumno VARCHAR(20) UNIQUE NOT NULL,
    nombre_alumno VARCHAR(100) NOT NULL,
    apellido_alumno VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    lugar_nacimiento VARCHAR(100),
    direccion VARCHAR(150),
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_inscripcion DATE,
    estado ENUM('activo', 'egresado', 'baja', 'suspendido') DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- =============================================
-- TABLAS DE RELACIÓN
-- =============================================

-- Tabla de relación alumno-tutor
CREATE TABLE alumno_tutor (
    id_alumno_tutor INT PRIMARY KEY AUTO_INCREMENT,
    id_alumno INT NOT NULL,
    id_tutor INT NOT NULL,
    es_principal TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_tutor) REFERENCES tutor(id_tutor) ON DELETE CASCADE,
    UNIQUE KEY unique_alumno_tutor (id_alumno, id_tutor)
);

-- Tabla de matriculación: alumno en curso
CREATE TABLE alumno_curso (
    id_alumno_curso INT PRIMARY KEY AUTO_INCREMENT,
    id_alumno INT NOT NULL,
    id_curso INT NOT NULL,
    anio_lectivo INT NOT NULL,
    estado ENUM('regular', 'libre', 'condicional') DEFAULT 'regular',
    fecha_inscripcion DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE,
    UNIQUE KEY unique_alumno_curso_anio (id_alumno, id_curso, anio_lectivo)
);

-- Tabla de asignación de docentes a materias en cursos
CREATE TABLE docente_curso_materia (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_docente INT NOT NULL,
    id_curso INT NOT NULL,
    id_materia INT NOT NULL,
    anio_lectivo INT NOT NULL,
    estado ENUM('activo', 'completado', 'inactivo') DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_docente) REFERENCES docente(id_docente) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES materia(id_materia) ON DELETE CASCADE,
    UNIQUE KEY unique_docente_curso_materia_anio (id_docente, id_curso, id_materia, anio_lectivo)
);

-- Tabla de correlatividades entre materias
CREATE TABLE materia_correlativa (
    id_correlativa INT PRIMARY KEY AUTO_INCREMENT,
    id_materia INT NOT NULL,
    id_materia_correlativa INT NOT NULL,
    tipo ENUM('obligatoria', 'recomendada') DEFAULT 'obligatoria',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_materia) REFERENCES materia(id_materia) ON DELETE CASCADE,
    FOREIGN KEY (id_materia_correlativa) REFERENCES materia(id_materia) ON DELETE CASCADE,
    UNIQUE KEY unique_correlativa (id_materia, id_materia_correlativa)
);

-- Tabla de estado de materias por alumno (CRÍTICA para promoción)
CREATE TABLE alumno_materia_estado (
    id_estado INT PRIMARY KEY AUTO_INCREMENT,
    id_alumno INT NOT NULL,
    id_materia INT NOT NULL,
    id_curso INT NOT NULL,
    anio_lectivo INT NOT NULL,
    estado ENUM('cursando', 'aprobada', 'desaprobada', 'libre', 'previa') DEFAULT 'cursando',
    calificacion_final DECIMAL(4,2) CHECK (calificacion_final BETWEEN 0 AND 10),
    fecha_estado DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES materia(id_materia) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE,
    UNIQUE KEY unique_alumno_materia_anio (id_alumno, id_materia, anio_lectivo)
);

-- Tabla de calificaciones
CREATE TABLE calificacion (
    id_calificacion INT PRIMARY KEY AUTO_INCREMENT,
    id_alumno INT NOT NULL,
    id_materia INT NOT NULL,
    id_docente INT NOT NULL,
    id_curso INT NOT NULL,
    anio_lectivo INT NOT NULL,
    cuatrimestre ENUM('1', '2') NOT NULL,
    nota_1 DECIMAL(4,2) CHECK (nota_1 BETWEEN 0 AND 10),
    nota_2 DECIMAL(4,2) CHECK (nota_2 BETWEEN 0 AND 10),
    nota_3 DECIMAL(4,2) CHECK (nota_3 BETWEEN 0 AND 10),
    promedio_cuatrimestre DECIMAL(4,2) CHECK (promedio_cuatrimestre BETWEEN 0 AND 10),
    periodo_complementario DECIMAL(4,2) CHECK (periodo_complementario BETWEEN 0 AND 10),
    calificacion_definitiva DECIMAL(4,2) CHECK (calificacion_definitiva BETWEEN 0 AND 10),
    estado ENUM('cursando', 'aprobada', 'desaprobada', 'libre') DEFAULT 'cursando',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES materia(id_materia) ON DELETE CASCADE,
    FOREIGN KEY (id_docente) REFERENCES docente(id_docente) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE
);

-- =============================================
-- TABLAS DE COMUNICACIONES
-- =============================================

-- Tabla de comunicaciones
CREATE TABLE comunicacion (
    id_comunicacion INT PRIMARY KEY AUTO_INCREMENT,
    asunto VARCHAR(150) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    destinatario_tipo ENUM('alumno', 'docente', 'curso', 'tutor', 'todos') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- Tabla de destinatarios de comunicaciones
CREATE TABLE comunicacion_destinatario (
    id_destinatario INT PRIMARY KEY AUTO_INCREMENT,
    id_comunicacion INT NOT NULL,
    id_alumno INT NULL,
    id_docente INT NULL,
    id_curso INT NULL,
    id_tutor INT NULL,
    email VARCHAR(100),
    asistio TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    FOREIGN KEY (id_comunicacion) REFERENCES comunicacion(id_comunicacion) ON DELETE CASCADE,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno) ON DELETE CASCADE,
    FOREIGN KEY (id_docente) REFERENCES docente(id_docente) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON DELETE CASCADE,
    FOREIGN KEY (id_tutor) REFERENCES tutor(id_tutor) ON DELETE CASCADE
);

-- =============================================
-- TABLA DE AUDITORÍA
-- =============================================

-- Tabla de log de actividades
CREATE TABLE log_actividad (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    accion VARCHAR(150) NOT NULL,
    tabla_afectada VARCHAR(100),
    id_registro INT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- =============================================
-- TRIGGERS PARA FUNCIONALIDADES AUTOMÁTICAS
-- =============================================

DELIMITER //

-- Trigger para actualizar estado de materia cuando se carga calificación final
CREATE TRIGGER after_calificacion_update
AFTER UPDATE ON calificacion
FOR EACH ROW
BEGIN
    DECLARE v_estado_materia ENUM('cursando', 'aprobada', 'desaprobada', 'libre', 'previa');
    
    -- Cuando se actualiza la calificación definitiva
    IF NEW.calificacion_definitiva IS NOT NULL AND OLD.calificacion_definitiva IS NULL THEN
        -- Determinar estado basado en la calificación
        IF NEW.calificacion_definitiva >= 6 THEN
            SET v_estado_materia = 'aprobada';
        ELSE
            SET v_estado_materia = 'desaprobada';
        END IF;
        
        -- Actualizar tabla alumno_materia_estado
        INSERT INTO alumno_materia_estado 
        (id_alumno, id_materia, id_curso, anio_lectivo, estado, calificacion_final, fecha_estado)
        VALUES (NEW.id_alumno, NEW.id_materia, NEW.id_curso, NEW.anio_lectivo, v_estado_materia, NEW.calificacion_definitiva, CURDATE())
        ON DUPLICATE KEY UPDATE
        estado = v_estado_materia,
        calificacion_final = NEW.calificacion_definitiva,
        fecha_estado = CURDATE(),
        updated_at = NOW();
        
        -- Actualizar estado en la misma tabla calificacion
        UPDATE calificacion SET estado = v_estado_materia WHERE id_calificacion = NEW.id_calificacion;
    END IF;
END//

DELIMITER ;

-- =============================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =============================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_alumno_nombre_apellido ON alumno(nombre_alumno, apellido_alumno);
CREATE INDEX idx_docente_nombre_apellido ON docente(nombre, apellido);
CREATE INDEX idx_tutor_nombre_apellido ON tutor(nombre, apellido);
CREATE INDEX idx_curso_anio_division ON curso(anio, division, turno);
CREATE INDEX idx_materia_nivel ON materia(nivel, estado);

-- Índices para consultas de estado académico
CREATE INDEX idx_alumno_materia_estado ON alumno_materia_estado(id_alumno, anio_lectivo, estado);
CREATE INDEX idx_calificacion_alumno_materia ON calificacion(id_alumno, id_materia, anio_lectivo);
CREATE INDEX idx_alumno_curso_anio ON alumno_curso(id_alumno, anio_lectivo);

-- Índices para comunicaciones
CREATE INDEX idx_comunicacion_fecha ON comunicacion(fecha_envio);
CREATE INDEX idx_comunicacion_destinatario ON comunicacion_destinatario(id_comunicacion, id_alumno, id_docente, id_curso, id_tutor);

-- =============================================
-- DATOS INICIALES DE EJEMPLO
-- =============================================

-- Insertar años lectivos
INSERT INTO anio_lectivo (anio, fecha_inicio, fecha_fin, estado) VALUES
(2023, '2023-03-01', '2023-12-15', 'finalizado'),
(2024, '2024-03-01', '2024-12-15', 'activo'),
(2025, '2025-03-01', '2025-12-15', 'planificacion');

-- Insertar materias de ejemplo por nivel
INSERT INTO materia (nombre, nivel, carga_horaria, ciclo, estado) VALUES
-- Nivel 1 (1° año)
('Matemática I', 1, 80, 'basico', 'activa'),
('Lengua y Literatura I', 1, 60, 'basico', 'activa'),
('Ciencias Naturales I', 1, 60, 'basico', 'activa'),
('Historia I', 1, 40, 'basico', 'activa'),
('Geografía I', 1, 40, 'basico', 'activa'),

-- Nivel 2 (2° año)
('Matemática II', 2, 80, 'basico', 'activa'),
('Lengua y Literatura II', 2, 60, 'basico', 'activa'),
('Física I', 2, 60, 'basico', 'activa'),
('Química I', 2, 60, 'basico', 'activa'),
('Historia II', 2, 40, 'basico', 'activa'),

-- Nivel 3 (3° año)
('Matemática III', 3, 80, 'basico', 'activa'),
('Lengua y Literatura III', 3, 60, 'basico', 'activa'),
('Física II', 3, 60, 'basico', 'activa'),
('Química II', 3, 60, 'basico', 'activa'),
('Biología', 3, 60, 'basico', 'activa');

-- Insertar correlatividades de ejemplo
INSERT INTO materia_correlativa (id_materia, id_materia_correlativa, tipo) VALUES
-- Para Matemática II se necesita Matemática I
(6, 1, 'obligatoria'),
-- Para Lengua II se necesita Lengua I
(7, 2, 'obligatoria'),
-- Para Física II se necesita Física I
(13, 8, 'obligatoria'),
-- Para Química II se necesita Química I
(14, 9, 'obligatoria');

-- =============================================
-- VISTAS ÚTILES PARA CONSULTAS FRECUENTES
-- =============================================

-- Vista para estado académico de alumnos
CREATE VIEW vista_estado_academico AS
SELECT 
    a.id_alumno,
    a.nombre_alumno,
    a.apellido_alumno,
    c.nombre as curso,
    m.nombre as materia,
    ame.estado,
    ame.calificacion_final,
    ame.anio_lectivo
FROM alumno a
JOIN alumno_materia_estado ame ON a.id_alumno = ame.id_alumno
JOIN materia m ON ame.id_materia = m.id_materia
JOIN curso c ON ame.id_curso = c.id_curso
WHERE a.deleted_at IS NULL AND ame.deleted_at IS NULL;

-- Vista para docentes con sus asignaciones
CREATE VIEW vista_docentes_asignaciones AS
SELECT 
    d.id_docente,
    d.nombre,
    d.apellido,
    c.nombre as curso,
    m.nombre as materia,
    dcm.anio_lectivo,
    dcm.estado as estado_asignacion
FROM docente d
JOIN docente_curso_materia dcm ON d.id_docente = dcm.id_docente
JOIN curso c ON dcm.id_curso = c.id_curso
JOIN materia m ON dcm.id_materia = m.id_materia
WHERE d.deleted_at IS NULL AND dcm.deleted_at IS NULL;

-- =============================================
-- MENSAJE FINAL
-- =============================================

SELECT 'Base de datos SGGS creada exitosamente' as mensaje;
SELECT 'Tablas creadas: 16' as resumen;
SELECT 'Triggers configurados: 1' as triggers;
SELECT 'Vistas creadas: 2' as vistas;