# This sets up a resource pool for the user.
# By setting up a resource pool you are basically separating server reources between users.
# Author: Jay Wood
# http://github.com/JayWood

[%USER%]

prefix = /home/$pool

user = %USER%
group = %USER%

listen = /home/$pool/run/php5-fpm.sock
listen.owner = %USER%
listen.group = www-data
listen.mode = 660

# These fields are optional
env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
env[TMPDIR] = /home/$pool/tmp
env[TEMP] = /home/$pool/tmp
env[TMP] = /home/$pool/tmp

# Setting up some logging, to make sure logs are stored in the user directory.
access.format = "%{HTTP_X_FORWARDED_FOR}e - [%t] \"%m %r%Q%q\" %s %l - %P %p %{seconds}d %{bytes}M %{user}C%% %{system}C%% \"%{REQUEST_URI}e\""
access.log = /home/$pool/log/$pool.access.log
slowlog = /home/$pool/log/$pool.slow.log
request_slowlog_timeout = 5s
catch_workers_output = yes

php_value[error_log] = /home/$pool/log/error.log
php_value[mail.log] = /home/$pool/log/mail.log
php_value[upload_tmp_dir] = /home/$pool/tmp
php_value[session.save_path] = /home/$pool/tmp

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
