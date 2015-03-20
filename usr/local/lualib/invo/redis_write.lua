-- INVO Redis (Write) Functions
--
-- All functions live in here for the moment

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

-- Redis Requires and Settings
local redis = require "resty.redis"

-- INVO Specific Settings
local hosts = {}

function _M.new(self)
    local red = redis:new()
    red:set_timeout(500)

    local ok, err = red:connect("127.0.0.1", 6379)

    if not ok then
        ngx.log(ngx.ERR, "[redis] failed to connect: ", err)
        return ngx.exit(500)
    end

    return setmetatable({ red = red, err = err }, mt)  
end

function _M.redis_keepalive(self)
    local ok, err = self.red:set_keepalive(60000, 50)
        if not ok then
            ngx.log(ngx.ERR, "[redis] failed to set keepalive: ", err)
            return
        end
end

function _M.add_namespace(self, namespace)
    res, err = red:sadd("namespaces", namespace)
    if not res then
        ngx.log(ngx.ERR, "[redis] failed add namespace: ", err)
        return ngx.exit(500)
    end
    self:redis_keepalive()
end


return _M
