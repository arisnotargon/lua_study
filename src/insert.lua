luasql = require "luasql.postgres";
env = assert (luasql.postgres())
con = assert (env:connect("hostaddr=127.0.0.1 dbname=54traveler user=root password=159753 port=5432"))
local name = ngx.var.arg_name;
local nickName = ngx.var.arg_nickName;
ngx.say(name,'==',nickName);
res = assert(con:execute('insert into "testlua" ("name","nickName") values(\'' .. name .. '\',\'' .. nickName .. '\')'))