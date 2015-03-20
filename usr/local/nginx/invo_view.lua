#!/usr/bin/lua

local redis = require "invo.redis_read"
local invo = require "invo.base"

local arg1 = string.lower(ngx.var[1])

local red = redis:new()

if arg1 == "namespaces" then
    res = red:get_namespaces()

elseif arg1 == "roles" then

    if not ngx.var.arg_namespace then
        ngx.status = 400
        ngx.say ("namespace parameter is required for roles lookups")
        return ngx.exit(ngx.HTTP_OK)
    else
        local namespace = string.lower(ngx.var.arg_namespace)
        res = red:get_roles(namespace)

    end

elseif arg1 == "hosts" then
    if not ngx.var.arg_role then
        ngx.status = 400
        ngx.say ("role parameter is required for hosts lookup")
        return ngx.exit(ngx.HTTP_OK)
    else
        local role = string.lower(ngx.var.arg_role)

        if ngx.var.arg_expand then
            -- Logic goes here to expand hosts definition
            res = red:get_hosts(role)
            res = string.sub(table.concat(res, "\n"), 1, -2)
            local hosts = {}
            for i in string.split(res, "\n") do
                if string.sub(i, 1, 1) ~= "#" then
                    -- Wrap this in a while loop for if roles table length > 0
                    -- then pop roles and add their hosts to hosts table
                    if string.sub(i, 1, 1) == "@" then
                        -- Look for more static hosts and includes
                    else
                        table.insert(hosts, i)
                    end
                end
            end
                --pre, range1, range2, post = string.match(v, "^([a-z0-9%.-]*)\\[?([0-9]+)*-?([0-9]+)*\\]?(.*)\n$")
                --table.insert(hosts, pre)
                --if range then
                --    for vv in invo:range(range) do
                --        table.insert(hosts, vv)
                --    end
                --end
                --if post then table.insert(hosts, post) end
            --table.concat(hosts, "\n")
            res = hosts
        else
            res = red:get_hosts(role)
        end

    end

elseif arg1 == "host" then
    if ngx.var.arg_mac or ngx.var.arg_ip or ngx.var.arg_name then
        if ngx.var.arg_mac then
            mac = string.lower(ngx.unescape_uri(ngx.var.arg_mac))
            res = red:get_host("mac", mac)
        end
        if ngx.var.arg_ip then 
            ip = string.lower(ngx.unescape_uri(ngx.var.arg_ip))
            res = red:get_host("ip", ip)
        end
        if ngx.var.arg_name then
            name = string.lower(ngx.unescape_uri(ngx.var.arg_name))
            res = red:get_host("name", name)
        end
    else
        ngx.status = 400
        ngx.say ("either mac, ip, or name parameter is required for host lookup")
        return ngx.exit(ngx.HTTP_OK)
    end
end

-- Order output if ?order=asc|desc
if arg1 == "namespaces" or arg1 == "roles" then
    if ngx.var.arg_order then
        if string.upper(ngx.var.arg_order) == "ASC" then
            -- Order res ASC
            table.sort(res)
        elseif string.upper(ngx.var.arg_order) == "DESC" then
            -- Order res DESC
            table.sort(res, function(a,b) return a>b end )
        end
    end
end

-- Format output as json unless ?format=json|csv
if ngx.var.arg_format then
    format = string.lower(ngx.var.arg_format)
    if format == "json" or format =="csv" then
        ngx.header.content_type = 'text/plain'
        ngx.say ( invo:format_output(res, format) )
    else
        ngx.status = 400
        ngx.say ("format can be of types: json or csv")
        return ngx.exit(ngx.HTTP_OK)
    end
else
    ngx.header.content_type = 'application/json'
    ngx.say ( invo:format_output(res, "json") )
end

