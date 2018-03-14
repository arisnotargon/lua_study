local time_helper = require "./src/time_helper"

local redis = require "resty.redis"
local red = redis:new()
local json = require("cjson")
red:set_timeout(1000) -- 1 sec超时

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local query_method = ngx.req.get_method()
local header = ngx.req.get_headers()
local ip = header["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
local ua = header['User-Agent']

--存入
local function redis_push(data)
    local pushOk, pushErr = red:lpush("trackUIDList", data)
    if not pushOk then
        ngx.log(ngx.ALERT, data)
    end
end

local function get_proc()
    --处理get请求
    local getArgs = ngx.req.get_uri_args();
    local pushTable = {}
    pushTable['ua'] = ua
    pushTable['created_at'] = time_helper.current_time_millis()
    pushTable['uri'] = ngx.var.request_uri --包含参数的uri
    pushTable['method'] = 'GET'

    redis_push(json.encode(pushTable))
    ngx.say(ngx.decode_base64("R0lGODlhAQABAIABAAAAAP///yH5BAEAAAEALAAAAAABAAEAAAICTAEAOw=="))
end

local function post_proc()
    --处理post请求
    ngx.req.read_body() --读取请求体,必须先执行这个函数才能读取到数据
    local reqData = ngx.req.get_body_data()
    local pushTable = {}
    local jsonStr = json.decode(reqData)
    jsonStr.ua = ua
    jsonStr.created_at = time_helper.current_time_millis()
    jsonStr = json.encode(jsonStr)
    redis_push(jsonStr)
end


--main:
if query_method == 'GET' then
    get_proc()
elseif query_method == 'POST' then
    post_proc()
end

