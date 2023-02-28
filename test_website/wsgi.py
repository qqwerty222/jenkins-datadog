from flaskr.__init__ import create_app
from werkzeug.middleware.proxy_fix import ProxyFix

app = ProxyFix(create_app(), x_for=1, x_host=1, x_proto=1)
