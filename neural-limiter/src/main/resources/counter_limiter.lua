-- 获取调用脚本时传入的第一个key值（用作限流的key）
local identity = KEYS[1]
-- 计数最小单元,默认为1
local countUnit = tonumber(ARGV[1])
-- 最大许可数
local maxCount = tonumber(ARGV[2])
--计数周期的超时时间(单位为毫秒)
local timeout = tonumber(ARGV[3])

-- 获取当前流量大小
local currentCount = tonumber(redis.call('get', identity) or '0')
-- 是否超出限流
if (currentCount + countUnit) > maxCount then
    -- 返回(拒绝)
    return 0, (currentCount + countUnit)
else
    -- 没有超出value + 1
   local nextCount = redis.call('INCRBY', identity, countUnit)
    -- 设置过期时间
    redis.call('PEXPIRE', identity, timeout)
    -- 返回(放行)
    return 1, nextCount
end