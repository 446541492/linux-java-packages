
upstream peak_80 {
	sticky;
	server 127.0.0.1:18010;
	server 127.0.0.1:18020;
	server 127.0.0.1:18030;
}
server {
	listen       80 ;
	server_name  www.mywebsite2.com 123.57.175.233;
	if ($request_method !~* GET|HEAD|POST) {
	   return 403;
	}
	rewrite ^(.*)\;jsessionid=(.*)$  $1   break;
	location ~ ^/(WEB-INF)/ {
		deny all;
	}
	location ~ \.(html|gif|jpg|jpeg|png|ico|rar|css|js|zip|txt|flv|swf|doc|ppt|xls|pdf)$ {
		 root /data/web/peak/www;
		 access_log off;
		 expires 24h;
	}
	location / {
		proxy_pass http://peak_80;
		proxy_redirect          off;
		proxy_set_header        Host $host;
		proxy_set_header        X-Real-IP $remote_addr;
		proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
		client_max_body_size    10m;
		client_body_buffer_size 128k;
		proxy_connect_timeout   300;
		proxy_send_timeout      300;
		proxy_read_timeout      300;
		proxy_buffer_size       4k;
		proxy_buffers           4 32k;
		proxy_busy_buffers_size 64k;
		proxy_temp_file_write_size 64k;
	}
}
