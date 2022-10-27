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

