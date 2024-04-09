-- 日期时间
-- 提高权重的原因：因为在方案中设置了大于 1 的 initial_quality，导致 rq sj xq dt ts 产出的候选项在所有词语的最后。
local function yield_cand(seg, text)
    local cand = Candidate('', seg.start, seg._end, text, '')
    cand.quality = 100
    yield(cand)
end

local M = {}

function M.init(env)
    local config = env.engine.schema.config
    env.name_space = env.name_space:gsub('^*', '')
    M.date = config:get_string(env.name_space .. '/date') or 'vdate'
    M.time = config:get_string(env.name_space .. '/time') or 'vtime'
    M.week = config:get_string(env.name_space .. '/week') or 'vweek'
    M.timestamp = config:get_string(env.name_space .. '/timestamp') or 'vtimestamp'
end

function M.func(input, seg, env)
    -- 日期
    if (input == M.date) then
        local current_time = os.time()
        yield_cand(seg, os.date('%Y-%m-%d', current_time))
        yield_cand(seg, os.date('%Y/%m/%d', current_time))
        -- yield_cand(seg, os.date('%Y.%m.%d', current_time))
        yield_cand(seg, os.date('%Y%m%d', current_time))
        yield_cand(seg, os.date('%Y年%m月%d日', current_time):gsub('年0', '年'):gsub('月0', '月'))

        -- 时间
    elseif (input == M.time) then
        local current_time = os.time()
        yield_cand(seg, os.date('%H:%M', current_time))
        yield_cand(seg, os.date('%H:%M:%S', current_time))

        -- 星期
    elseif (input == M.week) then
        local current_time = os.time()
        local week_tab = {'日', '一', '二', '三', '四', '五', '六'}
        local text = week_tab[tonumber(os.date('%w', current_time) + 1)]
        yield_cand(seg, '星期' .. text)
        -- yield_cand(seg, '礼拜' .. text)
        -- yield_cand(seg, '周' .. text)

        -- 时间戳（十位数，到秒，示例 1650861664）
    elseif (input == M.timestamp) then
        local current_time = os.time()
        yield_cand(seg, string.format('%d', current_time))
    end
end

return M
