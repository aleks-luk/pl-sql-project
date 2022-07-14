--- TABELE

CREATE TABLE products
    ( product_id    NUMBER(4) GENERATED ALWAYS AS IDENTITY PRIMARY KEY 
    , product_name  VARCHAR2(30)  
    );

CREATE TABLE regions  
    ( region_id      NUMBER   
                     CONSTRAINT region_id_nn NOT NULL 
    ,                CONSTRAINT reg_id_pk  
                        PRIMARY KEY (region_id) 
    , region_name    VARCHAR2(25)   
    );


CREATE TABLE countries   
    ( country_id      CHAR(2)   
                      CONSTRAINT country_id_nn NOT NULL 
    ,                 CONSTRAINT country_c_id_pk   
        	         PRIMARY KEY (country_id) 
    , country_name    VARCHAR2(40)   
    , region_id       NUMBER   
    ,                 CONSTRAINT countr_reg_fk  
        	         FOREIGN KEY (region_id)  
          	         REFERENCES regions (region_id)   
    )   
    ORGANIZATION INDEX;


CREATE TABLE locations  
    ( location_id    NUMBER(4)  NOT NULL 
                     CONSTRAINT loc_id_pk  
       		        PRIMARY KEY  
    , street_address VARCHAR2(40)  
    , postal_code    VARCHAR2(12)  
    , city           VARCHAR2(30)  
	             CONSTRAINT loc_city_nn  NOT NULL  
    , state_province VARCHAR2(25)  
    , country_id     CHAR(2)  
    ,                CONSTRAINT loc_c_id_fk  
       		        FOREIGN KEY (country_id)  
        	        REFERENCES countries(country_id) 
    );
    
CREATE TABLE departments  
    ( department_id    NUMBER(4) 
                       CONSTRAINT dept_id_pk  
       		          PRIMARY KEY 
    , department_name  VARCHAR2(30)  
	               CONSTRAINT dept_name_nn  NOT NULL  
    , manager_id       NUMBER(6)  
    , location_id      NUMBER(4)  
    ,                  CONSTRAINT dept_loc_fk  
       		          FOREIGN KEY (location_id)  
        	          REFERENCES locations (location_id)  
    );


CREATE TABLE jobs  
    ( job_id         VARCHAR2(10)  
                     CONSTRAINT job_id_pk  
      		        PRIMARY KEY 
    , job_title      VARCHAR2(35)  
	             CONSTRAINT job_title_nn  NOT NULL  
    , min_salary     NUMBER(6)  
    , max_salary     NUMBER(6)  
    );


CREATE TABLE employees  
    ( employee_id    NUMBER(6)  
                     CONSTRAINT emp_emp_id_pk  
                        PRIMARY KEY 
    , first_name     VARCHAR2(20)  
    , last_name      VARCHAR2(25)  
	             CONSTRAINT emp_last_name_nn  NOT NULL  
    , email          VARCHAR2(25)  
	             CONSTRAINT emp_email_nn  NOT NULL  
    , CONSTRAINT     emp_email_uk  
                     UNIQUE (email)  
    , phone_number   VARCHAR2(20)  
    , hire_date      DATE  
	             CONSTRAINT emp_hire_date_nn  NOT NULL  
    , job_id         VARCHAR2(10)  
	             CONSTRAINT emp_job_nn  NOT NULL  
    , salary         NUMBER(8,2)  
                     CONSTRAINT emp_salary_min  
                        CHECK (salary > 0)  
    , commission_pct NUMBER(2,2)  
    , manager_id     NUMBER(6)  
    ,                CONSTRAINT emp_manager_fk  
                        FOREIGN KEY (manager_id)  
                        REFERENCES employees 
    , department_id  NUMBER(4)  
    ,                CONSTRAINT emp_dept_fk  
                        FOREIGN KEY (department_id)  
                        REFERENCES departments 
    );


CREATE TABLE job_history  
    ( employee_id   NUMBER(6)  
	            CONSTRAINT jhist_employee_nn  NOT NULL  
    ,               CONSTRAINT jhist_emp_fk  
                       FOREIGN KEY (employee_id)  
                       REFERENCES employees  
    , start_date    DATE  
	            CONSTRAINT jhist_start_date_nn  NOT NULL  
    , end_date      DATE  
	            CONSTRAINT jhist_end_date_nn  NOT NULL  
    , job_id        VARCHAR2(10)  
	            CONSTRAINT jhist_job_nn  NOT NULL  
    ,               CONSTRAINT jhist_job_fk  
                       FOREIGN KEY (job_id)  
                       REFERENCES jobs  
    , department_id NUMBER(4)  
    ,               CONSTRAINT jhist_dept_fk  
                       FOREIGN KEY (department_id)  
                       REFERENCES departments 
    , CONSTRAINT    jhist_emp_id_st_date_pk  
                       PRIMARY KEY (employee_id, start_date) 
    , CONSTRAINT    jhist_date_interval  
                       CHECK (end_date > start_date)  
    ) ;
    
CREATE TABLE customers (
  customer_id 	INTEGER PRIMARY KEY
, first_name 	VARCHAR2(40)
, last_name 	VARCHAR2(50)
, is_company 	VARCHAR2(1)
)
;

CREATE TABLE customer_orders(
  order_id 		INTEGER PRIMARY KEY
, order_date 	DATE
, customer_id 	INTEGER
, product_id 	INTEGER
, quantity 		INTEGER
, status 		VARCHAR2(20) DEFAULT 'NEW'
, CONSTRAINT customer_id_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
, CONSTRAINT product_id_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);


CREATE TABLE order_payments(
  payment_id 	INTEGER PRIMARY KEY
, payment_date 	DATE DEFAULT SYSDATE
, order_id 		INTEGER
, status 		VARCHAR2(20) DEFAULT 'PENDING'
, CONSTRAINT order_id_fk FOREIGN KEY (order_id) REFERENCES customer_orders(order_id)
)
;

    
--- WIDOKI

CREATE OR REPLACE VIEW emp_details_view  
  (employee_id,  
   job_id,  
   manager_id,  
   department_id,  
   location_id,  
   country_id,  
   first_name,  
   last_name,  
   salary,  
   commission_pct,  
   department_name,  
   job_title,  
   city,  
   state_province,  
   country_name,  
   region_name)  
AS SELECT  
  e.employee_id,   
  e.job_id,   
  e.manager_id,   
  e.department_id,  
  d.location_id,  
  l.country_id,  
  e.first_name,  
  e.last_name,  
  e.salary,  
  e.commission_pct,  
  d.department_name,  
  j.job_title,  
  l.city,  
  l.state_province,  
  c.country_name,  
  r.region_name  
FROM  
  employees e,  
  departments d,  
  jobs j,  
  locations l,  
  countries c,  
  regions r  
WHERE e.department_id = d.department_id  
  AND d.location_id = l.location_id  
  AND l.country_id = c.country_id  
  AND c.region_id = r.region_id  
  AND j.job_id = e.job_id   
WITH READ ONLY;

-- SEKWENCJE

CREATE SEQUENCE locations_seq  
 START WITH     3300  
 INCREMENT BY   100  
 MAXVALUE       9900  
 NOCACHE  
 NOCYCLE;

CREATE SEQUENCE departments_seq  
 START WITH     280  
 INCREMENT BY   10  
 MAXVALUE       9990  
 NOCACHE  
 NOCYCLE;
 
 CREATE SEQUENCE employees_seq  
 START WITH     207  
 INCREMENT BY   1  
 NOCACHE  
 NOCYCLE;
 
 
---------------------------
-- aktualizacja 10/07/2022
---------------------------

ALTER TABLE products ADD status VARCHAR2(10);
ALTER TABLE products ADD price NUMBER(10, 2);


CREATE TABLE employees_to_talk (
  employee_id   INTEGER
, job_id        VARCHAR2(20)
, salary        NUMBER
, manager_ID    INTEGER
, department_id INTEGER
, days_to_end   NUMBER
)
;




 