#!/bin/bash

echo " System Resource Usage Report "

# CPU usage
echo "CPU Usage"
top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"% used"}'

# Memory usage
echo "Memory Usage:"
free -h | awk '/Mem:/ {print "Used: "$3" / Total: "$2}'

# Top 5 CPU-consuming processes
echo "Top 5 CPU-consuming processes:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 Memory-consuming processes
echo "Top 5 Memory-consuming processes:"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

