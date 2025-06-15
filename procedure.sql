USE pizzas;
DELIMITER $$
DROP PROCEDURE IF EXISTS ps_actualizar_precio_pizza $$
CREATE PROCEDURE IF NOT EXISTS ps_actualizar_precio_pizza(IN p_pizza_id INT, IN p_nuevo_precio DECIMAL(10, 2) )
BEGIN
    DECLARE _pro_pre_id INT; -- producto presentacion id
    DECLARE done INT DEFAULT 0;
    DECLARE _c_update_pro INT DEFAULT 0;
    DECLARE error_message VARCHAR(255) DEFAULT '';
    DECLARE cur_pro CURSOR FOR
        SELECT presentacion_id FROM producto_presentacion WHERE producto_id = p_producto_id AND presentacion_id <> 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Actualizar
    IF p_nuevo_precio > 0 THEN
        UPDATE producto_presentacion SET precio = p_nuevo_precio WHERE producto_id = p_producto_id AND presentacion_id = 1;
    ELSE
        SIGNAL SQLSTATE VALUE '40001'
                SET MESSAGE_TEXT = 'El precio debe ser mayor a 0';
    END IF;
    -- Validacion UPDATE
    IF ROW_COUNT() <= 0 THEN
    SET error_message = CONCAT('[4001]', ' No se encontró el producto');
        SIGNAL SQLSTATE VALUE '40001'
            SET MESSAGE_TEXT = error_message;
    ELSE
    
        OPEN cur_pro;

        leer_pro : LOOP
            FETCH cur_pro INTO _pro_pre_id;

        -- Validar fin del LOOP
            IF done THEN
                LEAVE leer_pro;
            END IF;
            
            UPDATE producto_presentacion 
            SET precio = p_nuevo_precio + (p_nuevo_precio * 0.11) 
            WHERE producto_id = p_producto_id AND presentacion_id = 2;
            UPDATE producto_presentacion 
            SET precio = p_nuevo_precio + (p_nuevo_precio * 0.22) 
            WHERE producto_id = p_producto_id AND presentacion_id = 3;

            IF ROW_COUNT() > 0 THEN
                SET _c_update_pro = _c_update_pro + 1;
            END IF;

        END LOOP leer_pro;
        CLOSE cur_pro;

        IF _c_update_pro > 0 THEN
            SET _c_update_pro = _c_update_pro + 1;
            SELECT 'Producto actualizado' AS Mensaje;
        ELSE
            SIGNAL SQLSTATE VALUE '40001'
                SET MESSAGE_TEXT = 'No se actualizó el precio de los productos';
        END IF;
    END IF;
END $$

CALL ps_actualizar_precio_pizza(1, 0)