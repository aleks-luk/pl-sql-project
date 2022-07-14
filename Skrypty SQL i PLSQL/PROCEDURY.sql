SET SERVEROUTPUT ON;

-- Mechanizm automatycznego oznaczania zamówień jako nieaktywne w przypadku braku zaakceptowanej płatności w terminie 8 dni od zamówienia.  
DROP PROCEDURE invalidate_orders;
CREATE OR REPLACE PROCEDURE invalidate_orders
    IS
        v_order_days_limit INTEGER := 8;
    BEGIN
        UPDATE customer_orders co
           SET status = 'INACTIVE'
         WHERE status = 'NEW'
           AND order_date < SYSDATE-v_order_days_limit
           AND NOT EXISTS (
                        SELECT 1
                          FROM order_payments op
                         WHERE op.order_id = co.order_id
                           AND op.status = 'APPROVED'
                           AND op.payment_date BETWEEN co.order_date AND co.order_date+v_order_days_limit
                            );
    END invalidate_orders;
/

-- Mechanizm generowania listy pracowników, którym umowa wygasa wcześniej niż zdefiniowane limity w tabeli job_limits.

DROP PROCEDURE generate_emp_to_talk;
CREATE OR REPLACE PROCEDURE generate_emp_to_talk
IS
BEGIN
    MERGE INTO employees_to_talk emp_t
		 USING (
				  SELECT emp.*
				       , job_l.days_left
					   , FLOOR(emp.expire_date- SYSDATE) AS days_to_end
					FROM employees emp
			  INNER JOIN job_limits job_l
					  ON job_l.job_id = emp.job_id
				   WHERE SYSDATE BETWEEN emp.expire_date - job_l.days_left  AND emp.expire_date
					 AND emp.expire_date > SYSDATE
             ) 
           source
        ON (
			emp_t.employee_id = source.employee_id
			)
    WHEN MATCHED THEN
        UPDATE
		   SET days_to_end = source.days_to_end
    WHEN NOT MATCHED THEN
		INSERT (
          employee_id   
        , job_id        
        , salary       
        , manager_ID    
        , department_id
        , days_to_end 
        )
        VALUES
        (
          source.employee_id   
        , source.job_id        
        , source.salary       
        , source.manager_ID    
        , source.department_id
        , source.days_to_end 
        );
END generate_emp_to_talk;
/