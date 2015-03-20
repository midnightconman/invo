-- INVO Functions
--
-- Base functions live here

local _M = { _VERSION = '0.01' }
local mt = { __index = _M }

function _M.new(self)
    return setmetatable({ nil }, mt)  
end

function _M.parse_post_args (self, key)
    local values = {}

    -- Return nil if no key specified
    if not key then return nil end

    ngx.req.read_body()
    local args = ngx.req.get_post_args()

    for k, v in pairs(args) do
        if k == key and type(v) == "table" then
            for kk, vv in pairs(v) do
                table.insert(values, vv)
            end
        else
            if k == key then
                table.insert(values, v)
            end
        end
    end
    return values
end

function string.split(s, sep, plain)
    local start = 1
    local done = false
    local function pass(i, j, ...)
        if i then
            local seg = s:sub(start, i - 1)
            start = j + 1
            return seg, ...
        else
            done = true
            return s:sub(start)
        end
    end
    return function()
        if done then return end
        if sep == '' then done = true return s end
        return pass(s:find(sep, start, plain))
    end
end

function _M.range (self, i, to)
    if i == nil then return end 
    if not to then to = i end
    -- step back one to include base i
    i = i - 1
    return function () if i >= to then return nil end i = i + 1 return i, i end 
end 

function _M.to_csv (self, t)
  local tt = {}
  for i, p in pairs(t) do
    table.insert(tt, p)
  end
  ss = table.concat(tt, ",")
  return string.sub(ss, 1, -1)
end

function _M.format_output (self, s, ty)
    if ty == "json" then
        local cjson = require "cjson"
        return cjson.encode(s)
    elseif ty == "csv" then
        return self:to_csv(s)
    end
end


return _M
