# Summary
This is just a collection of "common" functions on servers that may be performed infrequently enough to be easily forgotten.

# Tools/Descriptions
Below are some of the scripts included and their intended purpose.

## smart_stats.sh
Runs `smartctl` and prompts for the device to look at as well as greps through the output to display relevant statistics, since there's a lot of garbage in the output irrelevant to troubleshooting drive issues.
 You can run `./smart_stats.sh /dev/sda` and it will work, or `./smart_stats.sh` and it will prompt you to provide the path to the disk.
