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
#output=$(smartctl -a "$drive_path")

drive_type="sata"
output="smartctl 7.2 2020-12-30 r5155 [x86_64-linux-5.15.0-91-generic] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Family:     Western Digital Red (SMR)
Device Model:     WDC WD40EFAX-68JH4N0
Serial Number:    WD-WX42D10FC9U2
LU WWN Device Id: 5 0014ee 2bd0fcdd8
Firmware Version: 82.00A82
User Capacity:    4,000,787,030,016 bytes [4.00 TB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Rotation Rate:    5400 rpm
Form Factor:      3.5 inches
TRIM Command:     Available, deterministic, zeroed
Device is:        In smartctl database [for details use: -P show]
ATA Version is:   ACS-3 T13/2161-D revision 5
SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Tue Apr 16 04:18:04 2024 UTC
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART Status not supported: Incomplete response, ATA output registers missing
SMART overall-health self-assessment test result: PASSED
Warning: This result is based on an Attribute check.

General SMART Values:
Offline data collection status:  (0x00)	Offline data collection activity
					was never started.
					Auto Offline Data Collection: Disabled.
Self-test execution status:      ( 242)	Self-test routine in progress...
					20% of test remaining.
Total time to complete Offline 
data collection: 		(11100) seconds.
Offline data collection
capabilities: 			 (0x7b) SMART execute Offline immediate.
					Auto Offline data collection on/off support.
					Suspend Offline collection upon new
					command.
					Offline surface scan supported.
					Self-test supported.
					Conveyance Self-test supported.
					Selective Self-test supported.
SMART capabilities:            (0x0003)	Saves SMART data before entering
					power-saving mode.
					Supports SMART auto save timer.
Error logging capability:        (0x01)	Error logging supported.
					General Purpose Logging supported.
Short self-test routine 
recommended polling time: 	 (   2) minutes.
Extended self-test routine
recommended polling time: 	 (  36) minutes.
Conveyance self-test routine
recommended polling time: 	 (   2) minutes.
SCT capabilities: 	       (0x3039)	SCT Status supported.
					SCT Error Recovery Control supported.
					SCT Feature Control supported.
					SCT Data Table supported.

SMART Attributes Data Structure revision number: 16
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x002f   100   253   051    Pre-fail  Always       -       0
  3 Spin_Up_Time            0x0027   207   203   021    Pre-fail  Always       -       2650
  4 Start_Stop_Count        0x0032   100   100   000    Old_age   Always       -       156
  5 Reallocated_Sector_Ct   0x0033   200   200   140    Pre-fail  Always       -       0
  7 Seek_Error_Rate         0x002e   200   200   000    Old_age   Always       -       0
  9 Power_On_Hours          0x0032   060   060   000    Old_age   Always       -       29520
 10 Spin_Retry_Count        0x0032   100   100   000    Old_age   Always       -       0
 11 Calibration_Retry_Count 0x0032   100   100   000    Old_age   Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       156
192 Power-Off_Retract_Count 0x0032   200   200   000    Old_age   Always       -       146
193 Load_Cycle_Count        0x0032   198   198   000    Old_age   Always       -       7282
194 Temperature_Celsius     0x0022   112   111   000    Old_age   Always       -       35
196 Reallocated_Event_Count 0x0032   200   200   000    Old_age   Always       -       0
197 Current_Pending_Sector  0x0032   200   200   000    Old_age   Always       -       0
198 Offline_Uncorrectable   0x0030   100   253   000    Old_age   Offline      -       0
199 UDMA_CRC_Error_Count    0x0032   200   200   000    Old_age   Always       -       0
200 Multi_Zone_Error_Rate   0x0008   100   253   000    Old_age   Offline      -       0

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%     29519         -

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.
"

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
    smart_status=$(echo "$output" | grep "SMART overall-health self-assessment test result" | rev | cut -d ' ' -f 1 | rev)
    # Get the temperature
    temperature=$(echo "$output" | grep -i "Temperature_Celsius" | rev | cut -d ' ' -f 1 | rev)" Celsius"
    # Get the power on hours
    power_on_hours=$(echo "$output" | grep "Power_On_Hours" | rev | cut -d ' ' -f 1 | rev)
    # Get the power cycle count
    power_cycle_count=$(echo "$output" | grep "Power_Cycle_Count" | rev | cut -d ' ' -f 1 | rev)
    # Get the raw read error rate
    raw_read_error_rate=$(echo "$output" | grep "Raw_Read_Error_Rate" | rev | cut -d ' ' -f 1 | rev)
    # Get the reallocated sector count
    reallocated_sector_count=$(echo "$output" | grep "Reallocated_Sector_Ct" | rev | cut -d ' ' -f 1 | rev)
    # Get the seek error rate
    seek_error_rate=$(echo "$output" | grep "Seek_Error_Rate" | rev | cut -d ' ' -f 1 | rev)
    # Get the media and data integrity errors
    media_and_data_integrity_errors=$(echo "$output" | grep "Media_Wearout_Indicator" | rev | cut -d ' ' -f 1 | rev)
    # Get the error information log entries
    error_information_log_entries=$(echo "$output" | grep "Error_Information_Log_Entries" | rev | cut -d ' ' -f 1 | rev)
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
# Print the raw read error rate
if [[ $raw_read_error_rate == "" ]]; then
    raw_read_error_rate="Not Available"
else
    echo "Raw Read Error Rate: $raw_read_error_rate"
fi
# Print the reallocated sector count
if [[ $reallocated_sector_count == "" ]]; then
    reallocated_sector_count="Not Available"
else
    echo "Reallocated Sector Count: $reallocated_sector_count"
fi
# Print the seek error rate
if [[ $seek_error_rate == "" ]]; then
    seek_error_rate="Not Available"
else
    echo "Seek Error Rate: $seek_error_rate"
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

# Output summary
echo -e "- High temperature can kill drives.\n\t- Ensure the drive has adequate cooling if it indicates it has encountered high temperatures."
echo -e "- Seek Error Rate is the frequency of errors while positioning the drive head.\n\t- A high value indicates a problem with the drive read head being loose or out of calibration."
echo -e "- Reallocated Sector Count is the count of reallocated sectors.\n\t- A non-zero value is not necessarily a problem but on SSDs can indicate the NAND is beginning to fail."
echo -e "- Raw Read Error Rate is the rate of errors while reading raw data from a disk.\n\t- A high value indicates a problem with the drive itself."
echo -e "- Power On Hours is the total number of hours the drive has been powered on for.\n\t- This can be used to estimate the age of the drive."
echo -e "- Power Cycle Count is the number of times the drive has been power cycled.\n\t- For HDDs the act of powering on the drive can cause greater wear than simply leaving it spinning.\n\t- If this number is very high it might indicate the drive is experiencing wear at a faster rate than expected."
echo -e "- Media and Data Integrity Errors is the number of errors encountered while reading or writing data.\n\t- A high value indicates a problem with the drive accepting or retrieving data."
echo -e "- Error Information Log Entries is the number of errors logged by the drive.\n\t- A high value indicates the drive has encountered a large number of the above errors."
echo "======================== Drive Test Commands ========================"
echo "You may run a short or long test using the following commands:"
echo -e "\tsmartctl -t short $drive_path"
echo -e "\tsmartctl -t long $drive_path"
echo "You may check the test result using the following command:"
echo -e "\tsmartctl -l selftest $drive_path"