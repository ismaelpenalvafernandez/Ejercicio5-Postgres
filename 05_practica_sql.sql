--función sin parametro de entrada para devolver el precio máximo

CREATE OR REPLACE FUNCTION precio_maximo()
  RETURNS numeric 
  AS $$
DECLARE
  precio_max numeric;
BEGIN
  SELECT MAX(unit_price) INTO precio_max from products;
  RETURN precio_max;
END;
$$
LANGUAGE plpgsql;

SELECT precio_maximo();


--Obtener el numero de ordenes por empleado


CREATE OR REPLACE FUNCTION ordenes_empleado(eid numeric)
  RETURNS numeric 
  AS $$
DECLARE
  ordenes numeric;
BEGIN
  SELECT count(order_id) INTO ordenes from orders where employee_id = eid;
  RETURN ordenes;
END;
$$
LANGUAGE plpgsql;

SELECT ordenes_empleado(1);

--Obtener la venta de un empleado con un determinado producto

CREATE OR REPLACE FUNCTION venta_total(empleid numeric, prodid numeric)
RETURNS numeric
AS $$
DECLARE
  venta numeric;
BEGIN
  SELECT sum(od.quantity) INTO venta 
  from order_details od
  join orders o on od.order_id= o.order_id
  and o.employee_id = empleid
  and od.product_id = prodid;
  
 RETURN venta;
  
END;
$$
LANGUAGE plpgsql;

SELECT venta_total(1,1);

--Crear una funcion para devolver una tabla con producto_id, nombre, precio y unidades en stock,
--debe obtener los productos terminados en n

CREATE OR REPLACE FUNCTION obtener_productos_terminado()
RETURNS TABLE(producto_id smallint, producto_name character varying(40), unite_price real, unites_in_stock smallint) 
AS $$
BEGIN
  RETURN QUERY
  SELECT product_id , product_name, unit_price, units_in_stock
  FROM products
  WHERE product_name LIKE '%n';
END;
$$
LANGUAGE plpgsql;

SELECT * FROM obtener_productos_terminado();



-- Creamos la función contador_ordenes_anio()
--QUE CUENTE LAS ORDENES POR AÑO devuelve una tabla con año y contador

CREATE OR REPLACE FUNCTION contador_ordenes_anio()
  RETURNS TABLE(anio Numeric, ordenes bigint) 
  AS $$
BEGIN
  RETURN QUERY
  SELECT EXTRACT(YEAR FROM order_date), COUNT(*)
  FROM orders
  GROUP BY EXTRACT(YEAR FROM order_date)
  ORDER BY EXTRACT(YEAR FROM order_date);
END;
$$
LANGUAGE plpgsql;

SELECT * FROM contador_ordenes_anio();

3. --Lo mismo que el ejemplo anterior pero con un parametro de entrada que sea el año

CREATE OR REPLACE FUNCTION buscaranio(anno INTEGER)
  RETURNS TABLE(anio numeric, contador BIGINT) 
  AS $$
BEGIN
  RETURN QUERY
  SELECT EXTRACT(YEAR FROM order_date), COUNT(*)
  FROM orders
  WHERE EXTRACT(YEAR FROM order_date) = anno
  GROUP BY EXTRACT(YEAR FROM order_date)
  ORDER BY EXTRACT(YEAR FROM order_date);
END;
$$
LANGUAGE plpgsql;

SELECT * FROM buscaranio(1996);

4. --PROCEDIMIENTO ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE UNIDADES EN STOCK POR CATEGORIA

CREATE OR REPLACE FUNCTION categoria_stock(categorid INTEGER)
  RETURNS TABLE(avg_price double precision, sum_stock bigint) 
  AS $$
BEGIN
  RETURN QUERY
  SELECT avg(unit_price), sum(units_in_stock)
  FROM products
  WHERE category_id = categorid
  GROUP BY category_id;
 
END;
$$
LANGUAGE plpgsql;

SELECT * FROM categoria_stock(1);