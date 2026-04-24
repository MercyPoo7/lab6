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
SELECT * FROM logs_hashy ORDER BY fecha_ejecucion DESC;