-- INVO Redis (Read) Functions
--

-- Class Settings
local _M = { _VERSION = '0.02' }
local mt = { __index = _M }

-- Redis Requires and Settings
local redis = require "resty.redis"

-- INVO Specific Settings
local hosts = {}

function _M.new(self)
    local red = redis:new()
    red:set_timeout(1000)

    local ok, err = red:connect("127.0.0.1", 6380)

    if not ok then
        ngx.log(ngx.ERR, "[redis] failed to connect: ", err)
        return ngx.exit(500)
    end

    return setmetatable({ red = red, err = err }, mt)  
end

function _M.redis_keepalive(self)
    local ok, err = self.red:set_keepalive(600000, 30000)
        if not ok then
            ngx.log(ngx.ERR, "[redis] failed to set keepalive: ", err)
            return
        end
end

------------------
-- Get Functions -
------------------
function _M.get_namespaces(self)
    local res, err = self.red:smembers("namespaces")
    if not res then
        ngx.log(ngx.ERR, "[redis] failed get_namespaces: ", err)
        return ngx.exit(500)
    end
    self:redis_keepalive()
    return res
end

function _M.get_roles(self, namespace)
    -- One day I will have to make this a sscan, not smembers
    --res, err = red:sscan( namespace .. ".active", 0 )
    local res, err = self.red:smembers( namespace .. ".active" )
    if res == ngx.null then
        ngx.status = 404
        ngx.say (role .. " not found")
        return ngx.exit(ngx.HTTP_OK)
    elseif not res then
        ngx.log(ngx.ERR, "[redis] failed get_roles: ", err)
        return ngx.exit(500)
    end

    --for _, v in ipairs(res) do
    --    if res[1] == "0" then
    --    else
    --        local tt = {}
    --        --table.insert(tt,
    --    end
    --end

    self:redis_keepalive()
    return res
end

function _M.get_hosts(self, role)
    local res, err = self.red:get(role)

    if res == ngx.null then
        ngx.status = 404
        ngx.say (role .. " not found")
        return ngx.exit(ngx.HTTP_OK)
    elseif not res then
        ngx.log(ngx.ERR, "[redis] failed get_hosts: ", err)
        return ngx.exit(500)
    end

    self:redis_keepalive()
    return { ngx.decode_base64(res) }
end

function _M.get_hosts_expanded(self, role)
    res, err = self.red:get(role)

    if res == ngx.null then
        ngx.status = 404
        ngx.say (role .. " not found")
        return ngx.exit(ngx.HTTP_OK)
    elseif not res then
        ngx.log(ngx.ERR, "[redis] failed get_hosts_expanded: ", err)
        return ngx.exit(500)
    end

    self:redis_keepalive()
    return { ngx.decode_base64(res) }
end

function _M.get_host(self, t, value)
    if t == "mac" or t == "ip" then
        local res, err = self.red:get(value)
        value = res
    end
    local res, err = self.red:hgetall(value)

    if res == ngx.null then
        ngx.status = 404
        ngx.say (role .. " not found")
        return ngx.exit(ngx.HTTP_OK)
    elseif not res then
        ngx.log(ngx.ERR, "[redis] failed get_host: ", err)
        return ngx.exit(500)
    end

    -- Collate returned table
    local result = {}
    for idx = 1, #res, 2 do
        result[res[idx]] = res[idx + 1]
    end 

    self:redis_keepalive()
    return result
end


return _M
