-- CREACIÓN DE BASE DE DATOS
--  Responsable: Jose Carlos Mora Borbon

SET GLOBAL log_bin_trust_function_creators = 1;

-- BASE DE DATOS
DROP DATABASE IF EXISTS hashy_goloso;
CREATE DATABASE hashy_goloso CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hashy_goloso;

-- TABLA 1
CREATE TABLE mercado_negro (
    id                INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    categoria         VARCHAR(100)   NOT NULL,
    precio_referencia DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_mercado_categoria (categoria)
) ENGINE=InnoDB;

-- TABLA 2
CREATE TABLE inventario_pirata (
    id             INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    nombre_sucio   VARCHAR(200)   NOT NULL,
    categoria      VARCHAR(100)   NOT NULL,
    precio_finca   DECIMAL(10,2)  NOT NULL,
    fecha_ingreso  DATE           NOT NULL,
    meses_validez  INT UNSIGNED   NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- TABLA 3
CREATE TABLE logs_hashy (
    id         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    usuario    VARCHAR(100)  NOT NULL,
    fecha_hora DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mensaje    TEXT          NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- SEED
INSERT INTO mercado_negro (categoria, precio_referencia) VALUES
    ('Gomita',    20.00),
    ('Chocolate', 35.00),
    ('Caramelo',  15.00);

INSERT INTO inventario_pirata (nombre_sucio, categoria, precio_finca, fecha_ingreso, meses_validez) VALUES
('%%Caramelo_Dulce%%',   'Caramelo',  12.00, '2025-06-01',  3),
('##Chocolate**Rico##',  'Chocolate', 30.00, '2025-01-01',  3),
('!!Gomita_o_Fresa!!',   'Gomita',    18.00, '2026-01-01', 12),
('&&Caramelo__Menta&&',  'Caramelo',  14.00, '2026-01-01', 12),
('@@Gomita**Limon@@',    'Gomita',    19.00, '2025-06-01',  6),
('==Chocolate_Blanco==', 'Chocolate', 33.00, '2026-01-01', 12),
('##Gomita__Magica##',   'Gomita',    22.00, '2026-02-01', 12),
('**Caramelo#Fresa**',   'Caramelo',  13.00, '2026-01-01', 12),
('!!Chocolate_Negro!!',  'Chocolate', 36.00, '2026-01-01', 12),
('&&Gomita__Tropical&&', 'Gomita',    21.00, '2026-01-01', 12);