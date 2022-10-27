SET SERVEROUTPUT ON;

/*
Stworzenie algorytmu liczącego detaliczną cenę produktu na podstawie historii jego sprzedaży.
Jeśli towar został sprzedany w poprzednim miesiącu w ilości przekraczającej 500 to w kolejnym miesiącu jest cena powinna zostać podwyższona o 4%.
*/

CREATE OR REPLACE PACKAGE BODY orders_pkg
IS
FUNCTION get_product_price(in_product_id IN products.product_id%TYPE
							 , in_date IN DATE
							 ) RETURN products.price%TYPE
    IS
        v_sum 			NUMBER;
        v_new_price 	products.price%TYPE;
        v_limit_up 		NUMBER := 500;
        v_price_ind 	NUMBER := TO_NUMBER('0.04', '9.99');
    BEGIN
      SELECT SUM(quantity)
        INTO v_sum
        FROM customer_orders
       WHERE product_id = in_product_id
         AND order_date BETWEEN LAST_DAY(ADD_MONTHS(in_date, -2))+1 AND LAST_DAY((ADD_MONTHS(in_date, -1)))
        ;
        

        
        IF v_sum > v_limit_up THEN
            SELECT price *(1+v_price_ind)
              INTO v_new_price
              FROM products
             WHERE product_id = in_product_id;  
        ELSE
            SELECT price
              INTO v_new_price
              FROM products
             WHERE product_id = in_product_id;
        END IF;
        
        RETURN v_new_price;
	EXCEPTION 
          WHEN NO_DATA_FOUND 
          THEN DBMS_OUTPUT.PUT_LINE('Podany id produktu : '||in_product_id||' nie istnieje. Podaj prawidłowy product_id');
        RETURN v_new_price;
END get_product_price;

PROCEDURE update_product_price (in_product_id IN products.product_id%TYPE
							  , in_date IN DATE
                              , in_czy_modyfikowac_cene BOOLEAN
							  ) 
IS
        v_sum 			NUMBER;
        v_new_price 	products.price%TYPE;
        v_limit_up 		NUMBER := 500;
        v_price_ind 	NUMBER := TO_NUMBER('0.04', '9.99');
    BEGIN
                    SELECT orders_pkg.get_product_price(in_product_id, TO_DATE('2022-01-02', 'YYYY-MM-DD'))
                    INTO v_new_price
                    FROM products
                    WHERE product_id = in_product_id;

UPDATE products
SET price = v_new_price
WHERE product_id = in_product_id;
DBMS_OUTPUT.PUT_LINE('Sprzedaż produktu o ID = '||in_product_id||'  przekroczyła limit 500 i cena została podniesiona o 4 %. Nowa cena to '||v_new_price); 
EXCEPTION 
   WHEN NO_DATA_FOUND 
   THEN DBMS_OUTPUT.PUT_LINE('Podany id produktu : '||in_product_id||' nie istnieje. Podaj prawidłowy product_id');
   
    END update_product_price;
    END orders_pkg;
/
