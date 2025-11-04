#!/bin/python3
from datetime import datetime
from zoneinfo import ZoneInfo
import sys

#!/usr/bin/env python3

def convert_time(time_str, source_tz="America/Chicago"):
    """
    Convert time from source timezone to multiple target timezones.
    
    Args:
        time_str: Time in 24-hour format (HH:MM)
        source_tz: Source timezone (default: America/Chicago for CST)
    """
    # Parse input time
    try:
        time_obj = datetime.strptime(time_str, "%H:%M")
    except ValueError:
        print("Error: Time must be in HH:MM format (24-hour)")
        return
    
    # Create datetime with source timezone
    now = datetime.now()
    dt = datetime(now.year, now.month, now.day, 
                  time_obj.hour, time_obj.minute, 
                  tzinfo=ZoneInfo(source_tz))
    
    # Target timezones
    timezones = {
        "Hong Kong": "Asia/Hong_Kong",
        "Tokyo": "Asia/Tokyo",
        "Sydney": "Australia/Sydney",
        "PST": "America/Los_Angeles",
        "MST": "America/Denver",
        "CST": "America/Chicago",
        "EST": "America/New_York",
        "GMT": "GMT",
        "London": "Europe/London",
        "Tel Aviv": "Asia/Tel_Aviv",
        "Moscow": "Europe/Moscow"
    }
    
    # Print conversions
    print(f"\nConverting {time_str} from {source_tz}:\n")
    for name, tz in timezones.items():
        converted = dt.astimezone(ZoneInfo(tz))
        print(f"{name:12} {converted.strftime('%H:%M %Z')}")

def notes():
    print("""
Notes:
- Hong Kong operates on Hong Kong Time (HKT), which is UTC+8.
    - There is no daylight saving time observed in Hong Kong.
- Tokyo operates on Japan Standard Time (JST), which is UTC+9.
    - There is no daylight saving time observed in Tokyo.
- Sydney operates on Australian Eastern Daylight Time (AEDT), which is UTC+11 during daylight saving time, and Australian Eastern Standard Time (AEST), which is UTC+10 when daylight saving is not in effect.
    - Daylight saving time in Sydney starts on the first Sunday in October and ends on the first Sunday in April.
- PST (Pacific Standard Time) is UTC-8, and during daylight saving time it switches to PDT (Pacific Daylight Time), which is UTC-7.
- MST (Mountain Standard Time) is UTC-7, and during daylight saving time it switches to MDT (Mountain Daylight Time), which is UTC-6.
- CST (Central Standard Time) is UTC-6, and during daylight saving time it switches to CDT (Central Daylight Time), which is UTC-5.
- EST (Eastern Standard Time) is UTC-5, and during daylight saving time it switches to EDT (Eastern Daylight Time), which is UTC-4.
- GMT (Greenwich Mean Time) is UTC+0. The UK switches to BST (British Summer Time), which is UTC+1, during daylight saving time.
- London follows GMT and switches to BST during daylight saving time.
- Tel Aviv is in the Israel Standard Time (IST) zone, which is UTC+2.
    - Daylight saving time typically starts on the last Friday in March and ends on the last Sunday in October, when the time shifts to UTC+3.
- Moscow operates on Moscow Standard Time (MSK), which is UTC+3.
    - There is no daylight saving time observed in Moscow.
""")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python timezone_converter.py HH:MM [source_timezone]")
        print("Example: python timezone_converter.py 14:30")
        print("Example: python timezone_converter.py 14:30 America/New_York")
        sys.exit(1)
    
    time_input = sys.argv[1]
    source = sys.argv[2] if len(sys.argv) > 2 else "America/Chicago"
    
    convert_time(time_input, source)
    notes()