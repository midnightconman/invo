INVO is an Inventory robot that keeps track of your hosts in a simple RESTful
fashion. INVO is a very simple CMDB that features namespaces, roles, and hosts
and allows this information to be access via a simple RESTful API. INVO uses
OpenResty and redis in its current iteration.

Required Packages:
  * ngx_openresty
  * pcre-devel
  * pcre
  * redis
  * haproxy
    * socat
      * tcp_wrappers

Required Directories and Files:
    mkdir /usr
    mkdir /var/run/nginx
    mkdir /log/invo

Redis Schema:
    * (Namespaces) [Set]: namespaces
      * members: yourdomain

    * (Roles / Hosts) [Key / String]: yournamespace.hgp-fe.env-prod.loc-ca1
      * Can include static hostnames
      * Can include other roles
      * Can include host ranges ( something like cow[1-15,35-50,61].ca1.yourdomain.com )

    * (Host) [Hash]: cow5.ca1.yourdomain.com
      * Can include hosts MAC address
      * Can include hosts IP address
      * Can include hosts service tag
      * Can include hosts hardware specs
      * Can include hosts location

Required Users:
    * invo.invo 500.500

Required Groups:
    * invo:x:500:nobody
    * You also need to chmod 750 / to allow nobody group read access

Optional Changes for Performance:
    - Increase Open FD Limit at Linux OS Level

    Your operating system set limits on how many files can be opened by nginx
    server. You can easily fix this problem by setting or increasing system 
    open file limits under Linux. Edit file /etc/sysctl.conf, enter:
        # vi /etc/sysctl.conf

    Append / modify the following line:
        fs.file-max = 3268550

    Save and close the file. Edit /etc/security/limits.conf, enter:
        # vi /etc/security/limits.conf

    Set soft and hard limit for all users or nginx user as follows:
    ***NOTE*** Use <tab> not <space> for this file
    ***NOTE*** A good number to use here is 65536 for every 1GB or max 1048576
        invo       soft    nofile  1048576
        invo       hard    nofile  786432

    Save and close the file. Finally, reload the changes with sysctl command:
        # sysctl -p

