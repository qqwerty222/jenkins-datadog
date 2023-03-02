events {
    worker_connections 1024;
}

http {
    upstream websites {
        %{ for address in website_addresses ~}
        server ${address}:8000;
        %{endfor ~}
    }

    log_format upstream     '[$time_local] $remote_addr $upstream_addr '  
						    '"$request" $status $body_bytes_sent '
						    '"$http_user_agent"';

    server{
        listen      80;
        server_name localhost;
        access_log /var/log/nginx/access.log upstream;
        error_log  /var/log/nginx/error.log;
        location / {
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header Host $http_host;
                proxy_pass http://websites;
        }
    }
}