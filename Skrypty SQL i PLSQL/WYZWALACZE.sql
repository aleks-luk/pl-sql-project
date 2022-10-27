
--Mechanizm automatycznego zatwierdzania zamówienia klienta po dokonaniu płatności. 


DROP TRIGGER ai_order_payments_trg;	
CREATE OR REPLACE TRIGGER ai_order_payments_trg
	AFTER INSERT ON order_payments
	FOR EACH ROW
	WHEN (NEW.status = 'APPROVED')
	BEGIN
		 UPDATE customer_orders
			SET status = 'APPROVED'
		  WHERE order_id = :NEW.order_id;
	END;
	/

DROP TRIGGER bu_customer_orders_trg;
	CREATE OR REPLACE TRIGGER bu_customer_orders_trg
	BEFORE UPDATE ON customer_orders
	FOR EACH ROW
    WHEN (OLD.status = 'INACTIVE')
    BEGIN 
    RAISE_APPLICATION_ERROR(-20001,'Podane zamówienie o ID = ' ||:NEW.order_id|| 'już istnieje w bazie');
    	END bu_customer_orders_trg;
	/
	
CREATE OR REPLACE TRIGGER biu_salary_validation
FOR INSERT OR UPDATE OF SALARY ON employees
COMPOUND TRIGGER
    TYPE rec_emp IS RECORD (department_id departments.department_id%TYPE
                          , department_name departments.department_name%TYPE
                          , avg_dep_salary employees.salary%TYPE
                          , avg_comp_salary employees.salary%TYPE
                          ,  liczba NUMBER);
    TYPE at_emp IS TABLE OF rec_emp INDEX BY PLS_INTEGER;
    v_emp at_emp;
    BEFORE STATEMENT
    IS
    BEGIN
        SELECT d.department_id, 
               department_name,
               count(e.last_name) OVER (PARTITION BY d.department_id) "Liczba pracowników",
               ROUND(AVG(e.salary) OVER (PARTITION BY d.department_id),2) "Średnia pensja departamentu",
               (SELECT round(AVG(salary),2) FROM employees ) "Średnia pensja całej firmy"
               BULK COLLECT INTO v_emp
          FROM employees e
    INNER JOIN departments d
            ON d.department_id = e.department_id;
        
    END BEFORE STATEMENT;
    
    BEFORE EACH ROW
    IS
    BEGIN
        FOR i IN v_emp.FIRST..v_emp.LAST
        LOOP
            IF 
            :NEW.department_ID = v_emp(i).department_id AND :NEW.salary NOT BETWEEN v_emp(i).avg_dep_salary *TO_NUMBER('0.8', '9.9') AND v_emp(i).avg_dep_salary * TO_NUMBER('1.2','9.9')
            AND v_emp(i).liczba > 5
            THEN
                RAISE_APPLICATION_ERROR(-20001, ' Średnia pensja w departamencie '||v_emp(i).department_name||' wynosi '||v_emp(i).avg_dep_salary
                ||'. Nowa pensja pracownika '||:NEW.employee_ID||'('||:NEW.salary||') przekracza dopuszczalne 20% odchylenie od średniej.');
                
                ELSIF 
                :NEW.department_ID = v_emp(i).department_id AND :NEW.salary NOT BETWEEN v_emp(i).avg_comp_salary * TO_NUMBER('0.8', '9.9') AND v_emp(i).avg_comp_salary * TO_NUMBER('1.2','9.9')
                AND v_emp(i).liczba <= 5
                THEN
                RAISE_APPLICATION_ERROR(-20001, ' Średnia pensja wszystkich pracowników to '||v_emp(i).avg_comp_salary||
                '. Nowa pensja pracownika '||:NEW.employee_ID||'('||:NEW.salary||') przekracza dopuszczalne 20% odchylenie od średniej zarobków w firmie.');
                ELSE NULL;
                
                
            END IF;
        END LOOP;
    END BEFORE EACH ROW;
END biu_salary_validation;
/
