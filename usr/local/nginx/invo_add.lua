#!/usr/bin/lua

local red = require "invo.redis_write"
local invo = require "invo.base"

local arg1 = string.lower(ngx.var[1])

red:redis_connect("write")

if arg1 == "namespaces" then

    for _, v in ipairs(invo:parse_post_args("namespace")) do
        if not string.find(v, "[%[%]!\"#$%%&'()*+,%./:;<=>?@\\^`{|}~%s]") and string.len(v) <= 255 then
            red:add_namespace(v) 
        else
            ngx.status=400
            ngx.say("Namespaces have a max length of 255 characters.")
            ngx.say("Only underscore (_) and hyphen (-) are allowed.")
            return ngx.exit(ngx.HTTP_OK)
        end
    end

elseif arg1 == "roles" then
    -- No need to add roles, they are added when we add hosts
    ngx.status = 400
    ngx.say ("Roles are created when hosts are added, please use /hosts instead.")
    return ngx.exit(ngx.HTTP_OK)

elseif arg1 == "hosts" then
    if not ngx.var.arg_role then
        ngx.status = 400
        ngx.say ("role parameter is required for roles addition")
        return ngx.exit(ngx.HTTP_OK)
    else
        -- Check here for a POST of hosts definition
        local role = string.lower(ngx.var.arg_role)
        res = red:add_role_definition("")
    end

end
