#!/bin/bash

# Assign CLI arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check for correct number of arguments
if [ $# -ne 5 ]; then
	echo 'Error: incorrect number of parameters'
	exit 1
fi

hostname=$(hostname -f)
lscpu_out=`lscpu`

# Parse specs
cpu_number=$(echo "$lscpu_out" | grep -E '^CPU\(s\):' | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | grep -E 'Architecture:' | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | grep -E "Model name" | sed 's/.*: *//')
cpu_mhz=$(grep "cpu MHz" /proc/cpuinfo | head -n 1 | awk '{print $4}' | xargs)
l2_cache=$(echo "$lscpu_out" | grep "L2 cache" | sed 's/.*: *//' | awk '{print $1}')
total_mem=$(grep -E '^MemTotal:' /proc/meminfo | awk '{print $2}')
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# Construct INSERT statement from spec variables
insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem)
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# Execute INSERT statement
PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
 
exit $?
