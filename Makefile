
# invo - Host Inventory Robot
# copyright 2014 Jon Campbell - All Rights Reserved

INSTALL_ROOT := /
NGINX_FILES := invo_view.lua invo_add.lua invo_delete.lua invo_edit.lua invo_test.lua
LIB_FILES := base.lua redis_read.lua redis_write.lua
ETC_CONF_FILES := redis-master.conf redis-slave.conf haproxy-redis.conf haproxy-nginx.conf
MONIT_CONF_FILES := invo-redis-master invo-redis-slave invo-haproxy-redis invo-haproxy-nginx invo-nginx
DIRS := /etc/invo /usr/local/bin /var/log/invo /var/run/invo /var/cache/invo /usr/local/lualib/invo /usr/local/nginx

all: install

install:
	# Create and configure directories
	$(foreach dirs,$(DIRS), mkdir -p $(INSTALL_ROOT)$(dirs) ;)
	$(foreach dirs,$(DIRS), chown 500.500 $(INSTALL_ROOT)$(dirs) ;)
	$(foreach dirs,$(DIRS), chmod 750 $(INSTALL_ROOT)$(dirs) ;)
	# Installing invo files
	$(foreach n_files,$(NGINX_FILES), cp ./usr/local/nginx/$(n_files) $(INSTALL_ROOT)/usr/local/nginx/ ;)
	$(foreach l_files,$(LIB_FILES), cp ./usr/local/lualib/invo/$(l_files) $(INSTALL_ROOT)/usr/local/lualib/invo/ ;)
	cp ./usr/local/bin/invo-service $(INSTALL_ROOT)/usr/local/bin
	cp ./usr/local/nginx/nginx.conf $(INSTALL_ROOT)/usr/local/nginx/conf/
	$(foreach ec_files,$(ETC_CONF_FILES), cp ./etc/invo/$(ec_files) $(INSTALL_ROOT)/etc/invo/ ;)
	$(foreach monit_files,$(MONIT_CONF_FILES), cp ./etc/monit.d/$(monit_files) $(INSTALL_ROOT)/etc/monit.d/ ;)
	# Installing test files
	cp ./usr/local/lualib/luaunit.lua $(INSTALL_ROOT)/usr/local/lualib/luaunit.lua
	
remove:
	# Removing invo files
	$(foreach n_files,$(NGINX_FILES), rm -f $(INSTALL_ROOT)/usr/local/nginx/$(n_files) ;)
	$(foreach l_files,$(LIB_FILES), rm -f $(INSTALL_ROOT)/usr/local/lualib/invo/$(l_files) ;)
	rm -f  $(INSTALL_ROOT)/usr/local/nginx/conf/nginx.conf
	rm -f $(INSTALL_ROOT)/etc/invo/redis-master.conf
	rm -f $(INSTALL_ROOT)/etc/invo/redis-slave.conf
	# Removing invo dirs - Leaving logs though
	rmdir $(INSTALL_ROOT)/var/run/invo
	rmdir $(INSTALL_ROOT)/var/cache/invo
	rmdir $(INSTALL_ROOT)/usr/local/lualib/invo
	rmdir $(INSTALL_ROOT)/etc/invo
	# Removing test files
	rm -f $(INSTALL_ROOT)/usr/local/lualib/luaunit.lua

