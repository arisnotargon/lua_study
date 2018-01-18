local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 sec超时

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local count
count, err = red:get_reused_times()
if 0 == count then --count为0说明链接来自连接池
    --ok, err = red:auth("password")
    --if not ok then
    --    ngx.say("failed to auth: ", err)
    --    return
    --end
    ngx.say("from pool<br>")
elseif err then
    ngx.say("failed to get reused times: ", err)
    return
end

local getArgs = ngx.req.get_uri_args();

for k,v in pairs(getArgs) do
    ok, err = red:set(k, v)
    if not ok then
        ngx.say("failed to set ",k,": ", err)
        return
    end
    ngx.say("set ",k," ===>",v,"<br>")
end

-- 连接池大小是100个，并且设置最大的空闲时间是 10 秒
ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end



