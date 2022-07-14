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
      SELECT SUM(quantity)
        INTO v_sum
        FROM customer_orders
       WHERE product_id = in_product_id
         AND order_date BETWEEN LAST_DAY(ADD_MONTHS(in_date, -2))+1 AND LAST_DAY((ADD_MONTHS(in_date, -1)))
        ;
        
        CASE WHEN v_sum > v_limit_up 
        THEN
            SELECT price *(1+v_price_ind)
              INTO v_new_price
              FROM products
             WHERE product_id = in_product_id ;
           
          ELSE   
            SELECT price
              INTO v_new_price
              FROM products
             WHERE product_id = in_product_id;
           END CASE;
           
      CASE WHEN in_czy_modyfikowac_cene = TRUE 
        THEN
        UPDATE products
        SET price = v_new_price
        WHERE product_id = in_product_id;
        DBMS_OUTPUT.PUT_LINE('Sprzedaż produktu o ID = '||in_product_id||'  przekroczyła limit 500 i cena została podniesiona o 4 %. Nowa cena to '||v_new_price);
        
        ELSE
        DBMS_OUTPUT.PUT_LINE('Detaliczna cena produktu o ID = '||in_product_id||' po podwyżce wynosiła by '||v_new_price);
        END CASE;
   
    END update_product_price;
    END orders_pkg;
/