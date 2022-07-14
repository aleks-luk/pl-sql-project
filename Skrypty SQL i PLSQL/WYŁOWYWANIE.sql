SET SERVEROUTPUT ON; 

--------------------------------------------------------------------
SELECT p.*,
       orders_pkg.Get_product_price(p.product_id,
       to_date('2022-01-02', 'YYYY-MM-DD'))
FROM   products p; 
--------------------------------------------------------------------
BEGIN
    dbms_output.put_line(orders_pkg.get_product_price(3, SYSDATE));
END; 
--------------------------------------------------------------------
EXECUTE orders_pkg.update_product_price(3,SYSDATE,FALSE);
--------------------------------------------------------------------
EXECUTE generate_emp_to_talk;
--------------------------------------------------------------------
EXECUTE invalidate_orders;
--------------------------------------------------------------------



-- wywoływanie widoku

SELECT *
FROM emp_details_view;