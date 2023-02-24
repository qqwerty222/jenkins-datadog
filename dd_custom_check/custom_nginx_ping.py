from checks import AgentCheck
import subprocess

class NginxCheck(AgentCheck):
    def check(self, instance):

        # get ping result as a string
        value = (subprocess.run(["ping -c1 172.1.1.15"], shell=True, text=True, capture_output=True).stdout)

        # split by rows and get "time=..." from second row
        value = (((value.split("\n"))[1]).split(" "))[-2] 

        # split "time=..." and get number
        ping_avg = float((value.split('='))[1])

        self.gauge('custom.nginx.ping.avg', ping_avg)