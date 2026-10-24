local ok, err = pcall(function()
    local source = game:HttpGet("https://raw.githubusercontent.com/invisibilidade6-byte/zyon-piano/main/zyon-piano.lua", true)
    local run, problem = loadstring(source)
    assert(run, problem)
    run()
end)
if not ok then warn("ZYON Piano: " .. tostring(err)) end
