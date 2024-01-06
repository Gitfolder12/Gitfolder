#!/bin/bash

# Check if two parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <DB_CONNECTION_STRING> <OUTPUT_FOLDER>"
    exit 1
fi

DB_CONNECTION_STRING=$1
OUTPUT_FOLDER=$2

# Database Connection Details
DB_USER="SOE"
DB_PASSWORD="soe"
DB_HOST=$(uname -n)
DB_PORT="1521"
DB_SERVICENAME="PDB1.local"

# Path to your private key
PRIVATE_KEY="/home/oracle/.ssh/id_rsa"

# Function to execute Oracle SQL script
function execute_oracle_script() {
    echo "Executing Oracle SQL script..."
    sqlplus -S "${DB_USER}/${DB_PASSWORD}@//${DB_HOST}:${DB_PORT}/${DB_SERVICENAME}" <<EOF
SET TERMOUT OFF -- Disable output to the terminal

PROMPT Welcome to the Oracle Database.

-- SQL*Plus settings
SET VERIFY OFF
SET TERMOUT OFF
SET VERIFY OFF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET TERMOUT OFF
SET TRIMSPOOL ON
SET ECHO OFF

-- Start spooling to the output file in the specified folder
SPOOL $OUTPUT_FOLDER/home/oracle/outgoing/ORDERS_REPORT.txt

-- Define column formats
COLUMN ORDER_ID FORMAT 99999
COLUMN CUSTOMER_ID FORMAT 99999
COLUMN ADDRESS_ID FORMAT 99999
COLUMN DELIVERY_TYPE FORMAT A15
COLUMN ORDER_DATE FORMAT A30
COLUMN CUSTOMER_CLASS FORMAT A30
COLUMN ORDER_TOTAL FORMAT 99999
COLUMN ORDER_MODE FORMAT A10
COLUMN CUST_FULLNAME FORMAT A50
COLUMN CUST_EMAIL FORMAT A50
COLUMN CUSTOMER_ADDRESS FORMAT A100

-- SQL Query
SELECT  
    o.order_id,
    o.customer_id,
    a.address_id,
    o.delivery_type,
    TO_CHAR(o.order_date, 'DD-MON-YYYY HH24:MI:SS') AS ORDER_DATE,
    UPPER(c.customer_class) AS customer_class,
    o.order_total,
    o.order_mode,
    c.cust_first_name || ' ' || c.cust_last_name AS cust_fullname,
    c.cust_email,
    a.house_no_or_name || ', ' || a.street_name || ' : ' || a.country AS customer_address
FROM
    soe.orders o
    INNER JOIN soe.customers c ON o.customer_id = c.customer_id
    INNER JOIN soe.addresses a ON c.customer_id = a.customer_id
WHERE 
    o.order_date BETWEEN TO_DATE('01-01-2010', 'DD-MM-YYYY') AND TO_DATE('31-01-2010','DD-MM-YYYY');

-- Display the number of rows retrieved
SELECT 'Number of Rows Retrieved: ' || COUNT(*) FROM soe.orders o;

-- Stop spooling
SPOOL OFF
EXIT
EOF
}

# Call the function to execute Oracle SQL script
execute_oracle_script

