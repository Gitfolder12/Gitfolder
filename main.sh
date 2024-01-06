#!/bin/bash

# Contents of main.sh script

# Schedule the script to run every 10 minutes
(crontab -l ; echo "*/10* * * * /home/oracle/main.sh >/dev/null 2>&1") | crontab -

set -e

# Export SFTP Transfer variables as global
export SFTP_USER="sysadmin"
export SFTP_HOST="Hubnode.local"
export SFTP_DEST_DIR="/home/sysadmin/incoming/"
export OUTPUT_FILES=(
    "/home/oracle/outgoing/ORDERS_REPORT.txt"
    "/home/oracle/outgoing/sqlsoftn.rpm"
    # Add more file paths as needed
)

# Database Connection Details
DB_USER="SOE"
DB_PASSWORD="soe"
DB_HOST=$(uname -n)
DB_PORT="1521"
DB_SERVICENAME="PDB1.local"

# Function to execute Oracle SQL script
function execute_oracle_script() {
    echo "Executing Oracle SQL script..."
    ./report.sh "${DB_USER}/${DB_PASSWORD}@//${DB_HOST}:${DB_PORT}/${DB_SERVICENAME}" "/home/oracle/outgoing"
}

# Call the function to execute Oracle SQL script
execute_oracle_script

# Path to your private key
PRIVATE_KEY="/home/oracle/.ssh/id_dev_rsa"

# Function to perform SFTP transfer
function sftp_transfer() {
    for output_file in "${OUTPUT_FILES[@]}"; do
        echo "Connecting to ${SFTP_USER}@${SFTP_HOST} using SSH key..."
        sftp -i "${PRIVATE_KEY}" ${SFTP_USER}@${SFTP_HOST} <<EOF
cd ${SFTP_DEST_DIR}
put ${output_file}
bye
EOF
        echo "File successfully transferred to ${SFTP_HOST}."
    done
}

# Call the SFTP transfer function
sftp_transfer

# Clean up temporary files if needed
# rm -f "${OUTPUT_FILES[@]}"

