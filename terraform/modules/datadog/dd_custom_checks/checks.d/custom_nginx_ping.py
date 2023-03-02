from checks import AgentCheck
from datadog_checks.base.utils.subprocess_output import get_subprocess_output

class NginxCheck(AgentCheck):
    def check(self, instance):

        # get ping result as a string
        out, err, retcode = get_subprocess_output(["ping", "-c1", "172.1.1.5"], self.log, raise_on_empty_output=True)

        # split by rows and get "time=..." from second row
        out = (((out.split("\n"))[1]).split(" "))[-2] 

        # split "time=..." and get number
        ping_avg = float((out.split('='))[1])

        self.gauge('custom.nginx.ping.avg', ping_avg)