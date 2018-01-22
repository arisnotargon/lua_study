local redis = require "resty.redis"
local red = redis:new()
local json = require("cjson")
red:set_timeout(1000) -- 1 sec超时

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local count
count, err = red:get_reused_times()
if 0 == count then --count为0说明链接来自连接池
    --ok, err = red:auth("password") --密码登录
    --if not ok then
    --    ngx.say("failed to auth: ", err)
    --    return
    --end
    --ngx.say("from pool<br>")
elseif err then
    ngx.say("failed to get reused times: ", err)
    return
end
ngx.req.read_body() --读取请求体,必须先执行这个函数才能读取到数据
local  reqData = ngx.req.get_body_data()
ngx.say(reqData)
--local jsonData = json.decode(data);
--ngx.say(jsonData.cat);
red:lpush('list1',reqData)
