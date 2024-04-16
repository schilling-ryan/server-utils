#!/bin/bash

# Check if smartmontools is installed
if ! [ -x "$(command -v smartctl)" ]; then
  echo 'Error: smartmontools is not installed.' >&2
  exit 1
fi

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Check if the user has provided the drive path
if [ -z "$1" ]; then
    # Get the drive path from the user
    read -p "Enter the path to the drive to be scanned: " drive_path
else
    drive_path=$1
fi

# Check if drive is NVMe or SATA
if [[ $drive_path == *"nvme"* ]]; then
    # NVMe drive
    echo "NVMe drive detected, smartmontools output looks different for NVMe drives"
    drive_type="nvme"
else
    # SATA drive
    echo "SATA drive detected"
    drive_type="sata"
fi
echo "======================== Drive Information ========================"
# Run smartctl command and grep for "smart status is"
output=$(smartctl -a "$drive_path")

# Check if the drive is healthy
if [[ $output == *"PASSED"* ]]; then
    echo "Drive is healthy and passed SMART checks"
else
    echo "Drive is not healthy and did not pass SMART checks"
fi

# NVMe outputs
if [[ $drive_type == "nvme" ]]; then
    # Get the smart status
    smart_status=$(echo "$output" | grep -i "Critical Warning" | rev | cut -d ' ' -f 1 | rev)
    # Get the temperature
    temperature=$(echo "$output" | grep -i "temperature:" | rev | cut -d ' ' -f 1-2 | rev)
    # Get the power on hours
    power_on_hours=$(echo "$output" | grep -iE "(Power On Hours)|(power on hours)" | rev | cut -d ' ' -f 1 | rev)
    # Get the power cycle count
    power_cycle_count=$(echo "$output" | grep -iE "(Power Cycles)|(power cycle count)" | rev | cut -d ' ' -f 1 | rev)
    # Get the unsafe shutdown count
    unsafe_shutdown_count=$(echo "$output" | grep -iE "(Unsafe Shutdowns)|(unsafe shutdown count)" | rev | cut -d ' ' -f 1 | rev)
    # Get the media and data integrity errors
    media_and_data_integrity_errors=$(echo "$output" | grep -i "media and data integrity errors" | rev | cut -d ' ' -f 1 | rev)
    # Get the error information log entries
    error_information_log_entries=$(echo "$output" | grep -i "error information log entries" | rev | cut -d ' ' -f 1 | rev)
    # Get the warning composite temperature time
    warning_composite_temperature_time=$(echo "$output" | grep -iE "warning (composite|Comp.) temperature time" | rev | cut -d ' ' -f 1 | rev)
    # Get the critical composite temperature time
    critical_composite_temperature_time=$(echo "$output" | grep -iE "critical (composite|Comp.) temperature time" | rev | cut -d ' ' -f 1 | rev)
    # Get the temperature sensor for device
    temperature_sensor_for_device=$(echo "$output" | grep -i "temperature sensor for device" | rev | cut -d ' ' -f 1 | rev)
    # Get the temperature sensor for controller
    temperature_sensor_for_controller=$(echo "$output" | grep -i "temperature sensor for controller" | rev | cut -d ' ' -f 1 | rev)
    # Get the thermal management
    thermal_management=$(echo "$output" | grep -i "thermal management" | rev | cut -d ' ' -f 1 | rev)
    # Get the error information log entries
    error_information_log_entries=$(echo "$output" | grep -i "error information log entries" | rev | cut -d ' ' -f 1 | rev)
else
    # SATA outputs
    # Get the smart status
    smart_status=$(echo "$output" | grep "SMART overall-health self-assessment test result" | awk '{print $6}')
    # Get the temperature
    temperature=$(echo "$output" | grep "Temperature_Celsius" | awk '{print $10}')
    # Get the power on hours
    power_on_hours=$(echo "$output" | grep "Power_On_Hours" | awk '{print $10}')
    # Get the power cycle count
    power_cycle_count=$(echo "$output" | grep "Power_Cycle_Count" | awk '{print $10}')
    # Get the unsafe shutdown count
    unsafe_shutdown_count=$(echo "$output" | grep "Unsafe_Shutdown_Count" | awk '{print $10}')
    # Get the media and data integrity errors
    media_and_data_integrity_errors=$(echo "$output" | grep "Media_Wearout_Indicator" | awk '{print $10}')
    # Get the error information log entries
    error_information_log_entries=$(echo "$output" | grep "Error_Information_Log_Entries" | awk '{print $10}')
fi
# Print the smart status
if [[ $smart_status == "" ]]; then
    smart_status="Not Available"
else
    echo "SMART Status: $smart_status"
fi
# Print the temperature
if [[ $temperature == "" ]]; then
    temperature="Not Available"
else
    echo "Temperature: $temperature"
fi
# Print the temperature thresholds
if [[ $drive_type == "nvme" ]]; then
    # Print the warning composite temperature time
    if [[ $warning_composite_temperature_time == "" ]]; then
        warning_composite_temperature_time="Not Available"
    else
        echo "Warning Composite Temperature Time: $warning_composite_temperature_time"
    fi
    # Print the critical composite temperature time
    if [[ $critical_composite_temperature_time == "" ]]; then
        critical_composite_temperature_time="Not Available"
    else
        echo "Critical Composite Temperature Time: $critical_composite_temperature_time"
    fi
    # Print the temperature sensor for device
    if [[ $temperature_sensor_for_device == "" ]]; then
        temperature_sensor_for_device="Not Available"
    else
        echo "Temperature Sensor for Device: $temperature_sensor_for_device"
    fi
    # Print the temperature sensor for controller
    if [[ $temperature_sensor_for_controller == "" ]]; then
        temperature_sensor_for_controller="Not Available"
    else
        echo "Temperature Sensor for Controller: $temperature_sensor_for_controller"
    fi
    # Print the thermal management
    if [[ $thermal_management == "" ]]; then
        thermal_management="Not Available"
    else
        echo "Thermal Management: $thermal_management"
    fi
fi
# Print the power on hours
if [[ $power_on_hours == "" ]]; then
    power_on_hours="Not Available"
else
    echo "Power On Hours: $power_on_hours"
fi
# Print the power cycle count
if [[ $power_cycle_count == "" ]]; then
    power_cycle_count="Not Available"
else
    echo "Power Cycle Count: $power_cycle_count"
fi
# Print the unsafe shutdown count
if [[ $unsafe_shutdown_count == "" ]]; then
    unsafe_shutdown_count="Not Available"
else
    echo "Unsafe Shutdown Count: $unsafe_shutdown_count"
fi
# Print the media and data integrity errors
if [[ $media_and_data_integrity_errors == "" ]]; then
    media_and_data_integrity_errors="Not Available"
else
    echo "Media and Data Integrity Errors: $media_and_data_integrity_errors"
fi
# Print the error information log entries
if [[ $error_information_log_entries == "" ]]; then
    error_information_log_entries="Not Available"
else
    echo "Error Information Log Entries: $error_information_log_entries"
fi
echo "====================== End Drive Information ======================"

echo "You may run a short or long test using the following commands:"
echo "smartctl -t short $drive_path"
echo "smartctl -t long $drive_path"
echo "You may check the test result using the following command:"
echo "smartctl -l selftest $drive_path"