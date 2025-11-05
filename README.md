# Summary
This is just a collection of "common" functions on servers that may be performed infrequently enough to be easily forgotten.

# Tools/Descriptions
Below are some of the scripts included and their intended purpose.

## smart_stats.sh
Runs `smartctl` and prompts for the device to look at as well as greps through the output to display relevant statistics, since there's a lot of garbage in the output irrelevant to troubleshooting drive issues.
 You can run `./smart_stats.sh /dev/sda` and it will work, or `./smart_stats.sh` and it will prompt you to provide the path to the disk.

## timezone_converter.py
Converts a given timestamp (at a given timezone) to a variety of other timezones and includes notes about whether they follow DST(daylight savings time) or not, and what dates they change for DST if they do follow it.

## ping_devlist.py
Pings, using the tqdm library for a helpful progress bar, sending 1 packet with a timeout of 1 second, and trying IPv4 before attempting IPv6 if there's a failure.