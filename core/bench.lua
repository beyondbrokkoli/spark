-- core/bench.lua
BENCH = {}

function BENCH.Run(label, func)
    local start = os.clock()
    func()
    print(string.format("[%s] Time: %.6fs", label, os.clock() - start))
end
