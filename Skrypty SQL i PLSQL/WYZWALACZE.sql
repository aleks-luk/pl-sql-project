
--Mechanizm automatycznego zatwierdzania zamówienia klienta po dokonaniu płatności. 


DROP TRIGGER ai_order_payments_trg;	CREATE OR REPLACE TRIGGER ai_order_payments_trg
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