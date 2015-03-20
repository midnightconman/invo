#!/usr/bin/lua

local red = require "invo.redis_write"
local invo = require "invo.base"

local arg1 = string.lower(ngx.var[1])

red:redis_connect("write")

if arg1 == "namespaces" then

    for _, v in ipairs(invo:parse_post_args("namespace")) do
        if not string.find(v, "[%[%]!\"#$%%&'()*+,%./:;<=>?@\\^`{|}~%s]") and string.len(v) <= 255 then
            red:delete_namespace(v) 
        else
            ngx.status=400
            ngx.say("Namespaces have a max length of 255 characters")
            ngx.say("Only underscore (_) and hyphen (-) are allowed")
            return ngx.exit(ngx.HTTP_OK)
        end
    end

elseif arg1 == "roles" then
    for _, v in ipairs(invo:parse_post_args("namespace")) do
        if not string.find(v, "[%[%]!\"#$%%&'()*+,%./:;<=>?@\\^`{|}~%s]") and string.len(v) <= 255 then
            red:delete_hosts(v) 
        else
            ngx.status=400
            ngx.say ("role parameter is required for roles addition")
            return ngx.exit(ngx.HTTP_OK)
        end
    end

elseif arg1 == "hosts" then
    ngx.status = 400
    ngx.say ("Hosts definitions are deleted when roles are deleted, please use /roles instead.")
    return ngx.exit(ngx.HTTP_OK)

elseif arg1 == "host" then

    for _, v in ipairs(invo:parse_post_args("name")) do
        if not string.find(v, "[%[%]!\"#$%%&'()*+,%./:;<=>?@\\^`{|}~%s]") and string.len(v) <= 255 then
            red:delete_namespace(v) 
        else
            ngx.status=400
            ngx.say ("name parameter is required for host deletion")
            return ngx.exit(ngx.HTTP_OK)
        end
    end
    if not ngx.var.arg_name then
        ngx.status = 400
        return ngx.exit(ngx.HTTP_OK)
    else

end
