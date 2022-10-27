SET SERVEROUTPUT ON;

-- JOB  do uruchamiania procedury o nazwie 'invalidate_orders'
BEGIN
  DBMS_SCHEDULER.create_program (
    program_name   => 'program_oznaczania_zamówień_nieaktywnych',
    program_type   => 'PLSQL_BLOCK',
    program_action => 'BEGIN invalidate_orders; END;',
    enabled        => TRUE,
    comments       => 'Mechanizm automatycznego oznaczania zamówień jako nieaktywne w przypadku braku zaakceptowanej płatności w terminie 8 dni od zamówienia');
END;
/

BEGIN
  DBMS_SCHEDULER.create_schedule (
    schedule_name   => 'harmonogram_dla_oznaczania_zamówień_jako_nieaktywne',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=14; BYMINUTE=30;',
    end_date        => NULL,
    comments        => 'Powtarzany PN-PT o 14:30');    
END;
/

BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'Walidacja_zamówień',
    program_name    => 'program_oznaczania_zamówień_nieaktywnych',
    schedule_name   => 'harmonogram_dla_oznaczania_zamówień_jako_nieaktywne',
    enabled         => TRUE
    );
END;
/

