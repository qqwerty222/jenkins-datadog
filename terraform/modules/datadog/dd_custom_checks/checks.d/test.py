import os
import subprocess

website_node_count = int(os.environ['WEBSITE_COUNT'])
# website container ip range starts from 172.1.1.10 and last number in [-] included
ip_range = f"[10-{website_node_count + 9}]"

all_headers = subprocess.run([f"curl -I 'http://172.1.1.{ip_range}:8000'"], shell=True, capture_output=True, text=True).stdout
each_headers = all_headers.split("--_curl_--")

status_common = []

for rows in each_headers[1:website_node_count + 1]:
    status_header = (rows.split("\n"))[1]
    try: 
        status_code = (status_header.split(" "))[1] 
    except:
        status_code = "Failed"
            
    if status_code == "200":
        status_common.append(100)
    else:
        status_common.append(0)

for index, status in enumerate(status_common):
    print(f'custom.website_node{index + 1}.availability')

