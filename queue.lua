local queue = {}

local function empty ()
    local elems = {}
    local head = 1
    local tail = 1
    local function push(x)
        elems[tail] = x
        tail = tail + 1
    end
    local function pop()
        head = head + 1
        return elems[head - 1]
    end
    local function size()
        return tail - head
    end
    return {push = push, pop = pop, size = size}
end

queue.empty = empty

return queue
