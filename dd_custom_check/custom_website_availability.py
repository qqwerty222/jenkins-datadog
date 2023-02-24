from checks import AgentCheck
import subprocess

class NginxCheck(AgentCheck):
    def check(self, instance):


        all_headers = subprocess.run(["curl -I 'http://172.1.1.[10-12]:8000'"], shell=True, capture_output=True, text=True).stdout
        each_headers = all_headers.split("--_curl_--")

        status_common = []

        for rows in each_headers[1:4]:
            status_header = (rows.split("\n"))[1]
            try: 
                status_code = (status_header.split(" "))[1] 
            except:
                status_code = "Failed"
                    
            if status_code == "200":
                status_common.append(100)
            else:
                status_common.append(0)

        self.gauge('custom.website_node1.availability', status_common[0])
        self.gauge('custom.website_node2.availability', status_common[1])
        self.gauge('custom.website_node3.availability', status_common[2])
        self.gauge('custom.website.availability', (sum(status_common)/len(status_common)))