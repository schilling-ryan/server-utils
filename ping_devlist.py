#!/usr/bin/env python3
import argparse
import sys
import subprocess
from tqdm import tqdm
import re
import os
import concurrent.futures

failure_regex = re.compile(r'Name or service not known|Temporary failure in name resolution|unknown host|Address family for hostname not supported|connect: Network is unreachable|100% packet loss|No route to host|Network is unreachable|Host is down|Destination Host Unreachable|No response|No address associated with hostname', re.IGNORECASE)
results_regex = re.compile(r'icmp_seq|Name or service|Temporary|unknown host|100% packet loss', re.IGNORECASE)

def get_devices(filename, delimiter, field):
        devices = []
        try:
                with open(filename, 'r') as f:
                        for line in f:
                                parts = line.strip().split(delimiter)
                                if len(parts) >= field:
                                        h = parts[field-1].strip()
                                        if h:
                                                devices.append(h)
        except Exception as e:
                print(f"! Error reading file: {e}")
                sys.exit(1)
        return devices

def ping_host(host):
        host = ''.join(c for c in host if ord(c) >= 32 and ord(c) < 127)
        try:
                ping_cmd = ["ping", "-c", "1", "-w", "1", "-W", "1", host]
                result = subprocess.run(ping_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                output = result.stdout
                if re.search(failure_regex, output):
                        ping_cmd6 = ["ping6", "-c", "1", "-w", "1", "-W", "1", host]
                        result = subprocess.run(ping_cmd6, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                        output = result.stdout
                if re.search(failure_regex, output):
                        return [f"{host} : Address resolution or ping failure", False]
                # Extract summary line
                for line in output.splitlines():
                        if re.search(results_regex, line):
                                # Sanitize output using the sed from the original script
                                sanitized = line
                                sanitized = re.sub(r'[0-9]{2} bytes.+\(', '', sanitized)
                                sanitized = re.sub(r'[0-9]{1,3} bytes from ', '', sanitized)
                                sanitized = re.sub(r'\)?:.+time=', ' : ', sanitized)
                                sanitized = re.sub(r'ping6?: \S+: ', '', sanitized)
                                return [f"{host} : {sanitized}", True]
                return [f"{host} : Address resolution or ping failure", False]
        except Exception as e:
                return [f"{host} : Error - {e}", False]

def main():
        parser = argparse.ArgumentParser(description="Ping devices from a list")
        parser.add_argument("devlist", help="Path to the device list file")
        parser.add_argument("delimiter", nargs="?", default=" ", help="Delimiter for the device list")
        parser.add_argument("field", nargs="?", type=int, default=1, help="Field number for the device IPs")
        parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
        parser.add_argument("-f", "--file", help="Output file to save results")
        args = parser.parse_args()
        
        delimiter = args.delimiter if args.delimiter else " "
        field = args.field if args.field else 1
        if not args.delimiter:
                print("! Using space as default delimiter.")
        if not args.field:
                print("! Using field 1 as default column.")
        print(f"Reading devlist from: {args.devlist}")
        devices = get_devices(args.devlist, delimiter, field)
        if not devices:
                print("! No devices found. Exiting.")
                sys.exit(1)
        print(f"{len(devices)} device(s) found")
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            results = []
            failures = 0
            # Submit all tasks
            futures = [executor.submit(ping_host, host) for host in devices]
            # Show progress bar as tasks complete
            for f in tqdm(concurrent.futures.as_completed(futures), total=len(futures), desc="Pinging devices"):
                if not f.result()[1]:  # If ping was unsuccessful
                    failures += 1
                results.append(f.result()[0])
        if args.file:
            try:
                with open(args.file, 'w') as f:
                    for res in results:
                        f.write(res + '\n')
                print(f"Results saved to {args.file}")
            except Exception as e:
                print(f"! Error writing to file: {e}")
        for res in results:
                print(res)
        print(f"\n{len(devices)} devices pinged, {failures} failed.")

if __name__ == "__main__":
    main()