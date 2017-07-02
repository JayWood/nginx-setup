# Sets up the virtual host, basically the listening portion of the web server.

server {
    listen 80;
    listen [::]:80;

    server_name %DOMAIN%;

    root /home/%USER%/html/%DOMAIN%;
    index index.php index.html index.htm;

    #include snippets/parse_php;
    include wp_common;

    location / {
        index index.php index.html;
        try_files $uri $uri/ /index.php?$args;

        auth_basic "Restricted Content";
        auth_basic_user_file /home/%USER%/.htpasswd;
    }

    location ~ \.php$ {

        try_files      $uri =404;

        fastcgi_read_timeout 3600s;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 128k;

        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;

        fastcgi_param   PHP_VALUE "sendmail_path=/usr/bin/env /usr/local/bin/catchmail -f test@local.dev";

        fastcgi_pass   unix:/home/%USER%/run/php5-fpm.sock;
        fastcgi_index  index.php;

        include        /etc/nginx/fastcgi_params;
    }

}

include /etc/nginx/sites-available/%DOMAIN%.d/*;
