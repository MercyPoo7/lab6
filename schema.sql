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

-- LLAVE 1: fn_cernidor


DELIMITER $$

CREATE FUNCTION fn_cernidor(p_id INT)
RETURNS BOOLEAN
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_es_primo  BOOLEAN DEFAULT TRUE;
    DECLARE v_divisor   INT     DEFAULT 2;
    DECLARE v_limite    INT     DEFAULT 0;

    IF p_id IS NULL OR p_id < 2 THEN
        SET v_es_primo = FALSE;
        RETURN v_es_primo;
    END IF;

    SET v_limite = FLOOR(SQRT(p_id));

    WHILE v_divisor <= v_limite DO
        IF (p_id MOD v_divisor) = 0 THEN
            SET v_es_primo = FALSE;
            SET v_divisor  = v_limite + 1;
        ELSE
            SET v_divisor = v_divisor + 1;
        END IF;
    END WHILE;

    RETURN v_es_primo;
END$$

-- LLAVE 2: fn_reloj_arena


CREATE FUNCTION fn_reloj_arena(p_fecha DATE, p_meses INT)
RETURNS VARCHAR(10)
NOT DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_fecha_actual      DATE;
    DECLARE v_fecha_vencimiento DATE;
    DECLARE v_estado            VARCHAR(10);

    IF p_fecha IS NULL OR p_meses IS NULL THEN
        SET v_estado = 'Expirado';
        RETURN v_estado;
    END IF;

    SET v_fecha_actual      = CURDATE();
    SET v_fecha_vencimiento = DATE_ADD(p_fecha, INTERVAL p_meses MONTH);

    IF v_fecha_vencimiento > v_fecha_actual THEN
        SET v_estado = 'Fresco';
    ELSE
        SET v_estado = 'Expirado';
    END IF;

    RETURN v_estado;
END$$

DELIMITER ;


-- L1: Solo deben dar TRUE los IDs 2, 3, 5, 7
SELECT
    id,
    nombre_sucio,
    fn_cernidor(id) AS es_primo
FROM inventario_pirata
ORDER BY id;

-- L2: Solo deben dar 'Fresco' los que no han vencido
SELECT
    id,
    fecha_ingreso,
    meses_validez,
    DATE_ADD(fecha_ingreso, INTERVAL meses_validez MONTH) AS vence_el,
    fn_reloj_arena(fecha_ingreso, moses_validez)          AS estado
FROM inventario_pirata
ORDER BY id;

-- Doble filtro: los que pasan AMBAS llaves (deben ser IDs 3 y 7)
SELECT
    id,
    nombre_sucio,
    fn_cernidor(id)                                AS es_primo,
    fn_reloj_arena(fecha_ingreso, meses_validez)   AS estado
FROM inventario_pirata
WHERE fn_cernidor(id) = TRUE
  AND fn_reloj_arena(fecha_ingreso, meses_validez) = 'Fresco'
ORDER BY id;