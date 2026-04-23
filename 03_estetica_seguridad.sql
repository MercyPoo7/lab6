 DELIMITER $$
---Llave 5
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


--Llave 06
DELIMITER $$

CREATE FUNCTION fn_notario(p_texto TEXT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE v_usuario   VARCHAR(100);
    DECLARE v_mensaje   TEXT;
    DECLARE v_resultado TEXT;

    -- Paso 1: Obtener usuario y timestamp
    SET v_usuario = CURRENT_USER();

    -- Paso 2: Construir mensaje descriptivo
    SET v_mensaje = CONCAT('Pipeline procesó el texto: [', p_texto, '] en el timestamp: ', NOW());

    -- Paso 3: Insertar en bitácora
    INSERT INTO logs_hashy (nombre_funcion, mensaje_accion, usuario_db)
    VALUES ('fn_notario', v_mensaje, v_usuario);

    -- Paso 4: Retornar el mismo texto
    SET v_resultado = p_texto;
    RETURN v_resultado;
END$$

--Llave 7
CREATE FUNCTION fn_gran_sello(p_texto TEXT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE v_texto_entrada TEXT;
    DECLARE v_hash_bruto    VARCHAR(32);
    DECLARE v_sello_final   VARCHAR(32);

    -- Paso 1: Asignar texto a variable interna
    SET v_texto_entrada = p_texto;

    -- Paso 2: Aplicar MD5
    SET v_hash_bruto = MD5(v_texto_entrada);

    -- Paso 3: Garantizar longitud fija de 32 con LPAD
    SET v_sello_final = LPAD(v_hash_bruto, 32, '0');

    -- Paso 4: Retornar el sello
    RETURN v_sello_final;
END$$
DELIMITER ;