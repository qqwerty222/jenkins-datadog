from checks import AgentCheck
from datadog_checks.base.utils.subprocess_output import get_subprocess_output
import os 

class NginxCheck(AgentCheck):
    def check(self, instance):

        # get count containers with website
        website_node_count = int(os.environ['WEBSITE_COUNT'])
        
        # set range for curl, website container get ips starting from 172.1.1.10 (172.1.1.11, 172.1.1.12 ...)
        ip_range = f"[10-{website_node_count + 9}]"

        # get output from curl -I on each of conteiners
        out, err, retcode = get_subprocess_output(["curl", "-I", f"http://172.1.1.{ip_range}:8000"], self.log, raise_on_empty_output=True)
        
        # add output for each container in list
        each_headers = out.split("--_curl_--")

        status_common = []

        # parse output of curl -I and save status codes in list
        for rows in each_headers[1:]:
            status_header = (rows.split("\n"))[1]
            try: 
                status_code = (status_header.split(" "))[1] 
            except:
                status_code = "Failed"
                    
            if status_code == "200":
                status_common.append(100)
            else:
                status_common.append(0)

        # send each status code with name of the container
        for index, status in enumerate(status_common):
            self.gauge(f'custom.website_node{index + 1}.availability', status)