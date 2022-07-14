-- UPDATE ON PRODUCTS TABLE
UPDATE products SET price = 20 WHERE product_id = 1;
UPDATE products SET price = 25 WHERE product_id = 2;
UPDATE products SET price = 18 WHERE product_id = 3;
UPDATE products SET price = 200 WHERE product_id = 4;
UPDATE products SET price = 50 WHERE product_id = 5;
UPDATE products SET price = 170 WHERE product_id = 6;

-- UPDATE ON EMPLOYEES TABLE
UPDATE employees SET expire_date = TO_DATE('2022-01-02', 'YYYY-MM-DD') WHERE employee_id = 200;
UPDATE employees SET expire_date = TO_DATE('2022-02-01', 'YYYY-MM-DD') WHERE employee_id = 111;
UPDATE employees SET expire_date = TO_DATE('2022-01-31', 'YYYY-MM-DD') WHERE employee_id = 112;
UPDATE employees SET expire_date = TO_DATE('2021-12-31', 'YYYY-MM-DD') WHERE employee_id = 109;
UPDATE employees SET expire_date = TO_DATE('2022-04-15', 'YYYY-MM-DD') WHERE employee_id = 104;
UPDATE employees SET expire_date = TO_DATE('2022-02-08', 'YYYY-MM-DD') WHERE employee_id = 106;
UPDATE employees SET expire_date = TO_DATE('2022-01-16', 'YYYY-MM-DD') WHERE employee_id = 204;
UPDATE employees SET expire_date = TO_DATE('2022-01-22', 'YYYY-MM-DD') WHERE employee_id = 115;
UPDATE employees SET expire_date = TO_DATE('2022-01-31', 'YYYY-MM-DD') WHERE employee_id = 117;