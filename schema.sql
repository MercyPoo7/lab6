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
    fn_reloj_arena(fecha_ingreso, meses_validez)          AS estado
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


DELIMITER $$

-- Llave 3: fn_espia_tortuga
CREATE FUNCTION fn_espia_tortuga(p_categoria VARCHAR(100), p_precio_finca DECIMAL(10,2))
RETURNS DECIMAL(3,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_precio_mercado DECIMAL(10,2);
    DECLARE v_relacion DECIMAL(5,2);
    DECLARE v_factor DECIMAL(3,2);

    SELECT 
        precio_referencia,
        (p_precio_finca / precio_referencia) AS relacion
    INTO v_precio_mercado, v_relacion
    FROM mercado_negro
    WHERE categoria = p_categoria
    LIMIT 1;

    IF v_relacion > 1 THEN
        SET v_factor = 1.20;
    ELSE
        SET v_factor = 0.80;
    END IF;

    RETURN v_factor;
END$$

-- Llave 4: fn_purificador
CREATE FUNCTION fn_purificador(p_nombre_sucio VARCHAR(200))
RETURNS VARCHAR(200)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_limpio VARCHAR(200);

    IF p_nombre_sucio IS NULL THEN
        RETURN '';
    END IF;

    SET v_limpio = REGEXP_REPLACE(p_nombre_sucio, '[^a-zA-Z]', '');

    RETURN TRIM(v_limpio);
END$$


DELIMITER ;

-- L3: Validación de precios contra mercado
SELECT 
    i.categoria,
    i.precio_finca,
    m.precio_referencia AS precio_ref_mercado,
    fn_espia_tortuga(i.categoria, i.precio_finca) AS factor_espia,
    CASE 
        WHEN i.precio_finca > m.precio_referencia THEN 'Factor 1.2 (Caro)'
        ELSE 'Factor 0.8 (Barato)'
    END AS verificacion_logica
FROM inventario_pirata i
LEFT JOIN mercado_negro m 
    ON m.categoria = i.categoria
ORDER BY i.categoria;

-- L4: Limpieza de nombres sucios
SELECT 
    id,
    nombre_sucio,
    fn_purificador(nombre_sucio) AS nombre_purificado,
    LENGTH(nombre_sucio) AS largo_original,
    LENGTH(fn_purificador(nombre_sucio)) AS largo_limpio
FROM inventario_pirata
ORDER BY id;

DELIMITER $$

-- Llave 5
CREATE FUNCTION fn_escultor(p_nombre TEXT, p_factor DECIMAL(3,2))
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE v_texto_base TEXT;
    DECLARE v_resultado  TEXT;

    -- Paso 1: Guardar el texto base
    SET v_texto_base = p_nombre;

    -- Paso 2 y 3: Evaluar el factor y aplicar transformación
    IF p_factor > 1.00 THEN
        SET v_texto_base = UPPER(p_nombre);
    ELSE
        SET v_texto_base = LOWER(p_nombre);
    END IF;

    -- Paso 4: Concatenar sufijo y retornar
    IF p_factor > 1.00 THEN
        SET v_resultado = CONCAT(v_texto_base, '_PREMIUM');
    ELSE
        SET v_resultado = CONCAT(v_texto_base, '_estandar');
    END IF;

    RETURN v_resultado;
END$$


-- Llave 06
DELIMITER $$

CREATE FUNCTION fn_notario(p_texto TEXT)
RETURNS TEXT
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE v_usuario   VARCHAR(100);
    DECLARE v_mensaje   TEXT;
    DECLARE v_resultado TEXT;

    -- Paso 1: Obtener usuario y timestamp
    SET v_usuario = CURRENT_USER();

    -- Paso 2: Construir mensaje descriptivo
    SET v_mensaje = CONCAT('Pipeline procesó el texto: [', p_texto, '] en el timestamp: ', NOW());

    -- Paso 3: Insertar en bitácora
    INSERT INTO logs_hashy (usuario, mensaje)
    VALUES (v_usuario, v_mensaje);

    -- Paso 4: Retornar el mismo texto
    SET v_resultado = p_texto;
    RETURN v_resultado;
END$$

-- Llave 7
DROP FUNCTION IF EXISTS fn_gran_sello;

DELIMITER $$

-- Llave 7

DROP FUNCTION IF EXISTS fn_gran_sello;

DELIMITER $$

-- Llave 7
CREATE FUNCTION fn_gran_sello(p_texto TEXT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE v_texto_entrada TEXT;
    DECLARE v_hash_bruto    VARCHAR(64);
    DECLARE v_sello_final   VARCHAR(32);

    -- Paso 1: Asignar texto a variable interna
    SET v_texto_entrada = p_texto;

    -- Paso 2: Aplicar SHA2 en lugar de MD5
    SET v_hash_bruto = SHA2(v_texto_entrada, 256);

    -- Paso 3: Garantizar longitud fija de 32
    SET v_sello_final = LEFT(v_hash_bruto, 32);

    -- Paso 4: Retornar el sello
    RETURN v_sello_final;
END$$

DELIMITER ;
SELECT fn_gran_sello('prueba');

-- ==========================================================
-- CONSULTA MAESTRA FINAL
-- ==========================================================
SELECT
    GROUP_CONCAT(
        fn_gran_sello(
            fn_notario(
                fn_escultor(
                    fn_purificador(nombre_sucio),
                    fn_espia_tortuga(categoria, precio_finca)
                )
        )
        ORDER BY id ASC
        SEPARATOR ' # '
    ) AS resultado_final_del_trio
FROM inventario_pirata
WHERE
    fn_cernidor(id) = TRUE
    AND
    fn_reloj_arena(fecha_ingreso, meses_validez) = 'Fresco';

-- ==========================================================
-- VERIFICACIÓN DE BITÁCORA
-- ==========================================================
SELECT * FROM logs_hashy ORDER BY fecha_hora DESC;