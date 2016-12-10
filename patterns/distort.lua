-- I read like 100 pages about computational fluid dynamics while writing this code
-- and ended up using none of it, I just wanted you to know that.

-- The first version of this code took about 5 minutes to run when you started a new
-- game. Be glad it's been sped up a lot.

-- I hope this is the last time I have to implement Perlin noise in Lua. I did at
-- least 3 totally different implementations here just trying to get it fast and
-- accurate enough.

distort_light = {
        [21] = 1,
        [51] = 1
    }
distort_heavy = {
        [51] = 1,
        [101] = 0.3,
        [201] = 1,
        [401] = 0.8,
        [1601] = 0.5,
        [5001] = 0.5
    }

distort_default = distort_light

function Distort(pattern, wavelengths)
    local pget = pattern.get
    local w = wavelengths or distort_default
    local w_str = '{ '
    for a, b in pairs(w) do
        w_str = w_str .. '[' .. a .. '] = ' .. b .. ', '
    end
    w_str = w_str .. '}'

    -- The distortion repeats with a period of N (times wavelength)
    local N = 47
    local NN = N * N
    -- Each unit square of Perlin noise is sampled in k x k places,
    -- and then interpolated within those samples.
    local k = 6
    local kN = k * N
    local kkNN = k * k * N * N

    -- 1 / 100 for midpoint method seems good
    -- 1 / 8 for RK4
    local maxstepsize = 1 / 8
    local integration_time = 0.1
    local numsteps = math.ceil(integration_time / maxstepsize)

    -- half of the true stepsize 
    local stepsize_ = (integration_time / numsteps) / 2

    local data

    -- rand_vectors: N x N array of unit vectors
    -- noise_: N x N x 7 array of numbers
    --      noise_[i * N + j] holds coefficients of a polynomial:
    --      a1 x + a2 y + a3 x^2 + a4 xy + a5 y^2 + a6 x^2y + a7 xy^2
    -- noise: N x N x 8 array of numbers
    --      noise[i * N + j] holds four vectors
    -- map: (N * k) x (N * k) x 2 array of images of the distortion map
    -- land: infinite 2D array of whether each square is land or water
    --
    -- ix * N + iy gives index corresponding to the integer x,y values (ix, iy)

    local function make_rand_vectors()
        for i = 0, NN-1 do
            local a = math.random() * 2 * math.pi
            data.rand_vectors[i] = {math.cos(a), math.sin(a)}
        end
    end

    local function calculate_noise_coefficients_()
        local r = data.rand_vectors
        for i = 0, NN-1 do
            -- x, y, x^2, xy, y^2, x^2y, xy^2
            local a = {0, 0, 0, 0, 0, 0, 0}

            local cx = r[i][1]
            local cy = r[i][2]
            a[1] = a[1] + cx
            a[2] = a[2] + cy
            a[3] = a[3] - cx
            a[4] = a[4] - cx - cy
            a[5] = a[5] - cy
            a[6] = a[6] + cx
            a[7] = a[7] + cy

            cx = r[(i + N) % NN][1]
            cy = r[(i + N) % NN][2]
            a[3] = a[3] + cx
            a[4] = a[4] + cy
            a[6] = a[6] - cx
            a[7] = a[7] - cy

            cx = r[(i + 1) % NN][1]
            cy = r[(i + 1) % NN][2]
            a[4] = a[4] + cx
            a[5] = a[5] + cy
            a[6] = a[6] - cx
            a[7] = a[7] - cy

            cx = r[(i + N + 1) % NN][1]
            cy = r[(i + N + 1) % NN][2]
            a[6] = a[6] + cx
            a[7] = a[7] + cy

            data.noise_[i] = a
        end
    end

    local function height_(x, y)
        local ix = math.floor(x)
        local iy = math.floor(y)
        x = x - ix
        y = y - iy

        local a = data.noise[(ix % N) * N + (iy % N)]
        return ((a[6] * y + a[3]) * x + (a[7] * y + a[4]) * y + a[1]) * x + (a[5] * y + a[2]) * y
    end

    local function height_dx_(x, y)
        local ix = math.floor(x)
        local iy = math.floor(y)
        x = x - ix
        y = y - iy

        local a = data.noise_[(ix % N) * N + (iy % N)]
        return 2 * (a[6] * y + a[3]) * x + (a[7] * y + a[4]) * y + a[1]
    end

    local function height_dy_(x, y)
        local ix = math.floor(x)
        local iy = math.floor(y)
        x = x - ix
        y = y - iy

        local a = data.noise_[(ix % N) * N + (iy % N)]
        return 2 * (a[7] * x + a[5]) * y + (a[6] * x + a[4]) * x + a[2]
    end

    local function calculate_noise_coefficients()
        local r = data.rand_vectors
        for i = 0, NN-1 do
            local n = {0, 0, 0, 0, 0, 0, 0, 0}
            n[1] = r[i][1]
            n[2] = r[i][2]
            n[3] = r[(i + N) % NN][1] - r[i][1]
            n[4] = r[(i + N) % NN][2] - r[i][2]
            n[5] = r[(i + 1) % NN][1] - r[i][1]
            n[6] = r[(i + 1) % NN][2] - r[i][2]
            n[7] = r[(i + N + 1) % NN][1] - r[(i + N) % NN][1] - r[(i + 1) % NN][1] + r[i][1]
            n[8] = r[(i + N + 1) % NN][2] - r[(i + N) % NN][2] - r[(i + 1) % NN][2] + r[i][2]
            data.noise[i] = n
        end
    end

    local function smooth(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function dsmooth(t)
        return t * t * (t * (t * 30 - 60) + 30)
    end

    -- returns h(x, y), dh/dx(x, y), and dh/dy(x, y)
    local function heights(x, y)
        local ix = math.floor(x)
        local iy = math.floor(y)
        x = x - ix
        y = y - iy

        local sx = x*x*x*(x*(x*6-15)+10)
        local sy = y*y*y*(y*(y*6-15)+10)
        local dsx = x*x*(x*(x*30-60)+30)
        local dsy = y*y*(y*(y*30-60)+30)

        local n = data.noise[(ix % N) * N + (iy % N)]
        return {
                -- (n[1]*x+n[2]*y) +
                -- (n[3]*x+n[4]*y) * sx +
                -- (n[5]*x+n[6]*y) * sy +
                -- (n[7]*x+n[8]*y) * sx * sy,
                0,
                n[1] +
                n[3] * sx + (n[3]*x+n[4]*y) * dsx +
                n[5] * sy +
                (n[7] * sx + (n[7]*x+n[8]*y) * dsx) * sy,
                n[2] +
                n[4] * sx +
                n[6] * sy + (n[5]*x+n[6]*y) * dsy +
                (n[8] * sy + (n[7]*x+n[8]*y) * dsy) * sx
            }
        
    end

    local function compute_map(x, y)
        local x0 = x
        local y0 = y

        -- local h = heights(x, y)[1]

        for i = 1, numsteps do
            -- midpoint method, a second-order Runge-Kutta method
            -- local hs1 = heights(x, y)
            -- local hs2 = heights(x - hs1[3] * stepsize_, y + hs1[2] * stepsize_)
            -- x = x - hs2[3] * stepsize_ * 2
            -- y = y + hs2[2] * stepsize_ * 2

            -- RK4
            local hs1 = heights(x, y)
            local hs2 = heights(x - hs1[3] * stepsize_,     y + hs1[2] * stepsize_)
            local hs3 = heights(x - hs2[3] * stepsize_,     y + hs2[2] * stepsize_)
            local hs4 = heights(x - hs3[3] * stepsize_ * 2, y + hs3[2] * stepsize_ * 2)
            x = x - (stepsize_ / 3) * (hs1[3] + 2*hs2[3] + 2*hs3[3] + hs4[3])
            y = y + (stepsize_ / 3) * (hs1[2] + 2*hs2[2] + 2*hs3[2] + hs4[2])

            -- Correct back to the desired contour
            -- For some reason, the following seems to behave really poorly
            -- local hs = heights(x, y)
            -- local alpha = (h - hs[1]) / (hs[2] * hs[2] + hs[3] * hs[3])
            -- if alpha == alpha then
                -- x = x + hs[2] * alpha / 4
                -- y = y + hs[3] * alpha / 4
            -- end
        end
        return {x - x0, y - y0}
    end

    local function sample_distortion_map()
        for i = 0, kN - 1 do
            for j = 0, kN - 1 do
                -- data.map[i * kN + j] = compute_map(i / k, j / k)
                local a = compute_map(i / k, j / k)
                data.map[i * kN + j] = a[1]
                data.map[kkNN + i * kN + j] = a[2]
            end
        end
    end

    local function interpolate_map(x, y)
        x = x * k
        y = y * k
        local ix = math.floor(x)
        local iy = math.floor(y)
        x = x - ix
        y = y - iy
        local i = (ix % kN) * kN + (iy % kN)

        local rx = 0
        local ry = 0

        local m = data.map
        rx = rx + m[i]                              * (1 - x) * (1 - y)
        ry = ry + m[i + kkNN]                       * (1 - x) * (1 - y)

        rx = rx + m[(i + kN) % kkNN]                * x * (1 - y)
        ry = ry + m[((i + kN) % kkNN) + kkNN]       * x * (1 - y)

        rx = rx + m[(i + 1) % kkNN]                 * (1 - x) * y
        ry = ry + m[((i + 1) % kkNN) + kkNN]        * (1 - x) * y

        rx = rx + m[(i + kN + 1) % kkNN]            * x * y
        ry = ry + m[((i + kN + 1) % kkNN) + kkNN]   * x * y

        --[[
        local a = data.map[i]
        rx = rx + a[1] * (1 - x) * (1 - y)
        ry = ry + a[2] * (1 - x) * (1 - y)

        a = data.map[(i + kN) % kkNN]
        rx = rx + a[1] * x * (1 - y)
        ry = ry + a[2] * x * (1 - y)

        a = data.map[(i + 1) % kkNN]
        rx = rx + a[1] * (1 - x) * y
        ry = ry + a[2] * (1 - x) * y

        a = data.map[(i + kN + 1) % kkNN]
        rx = rx + a[1] * x * y
        ry = ry + a[2] * x * y
        ]]

        return {rx, ry}
    end

    local function create()
        data = {}
        data.rand_vectors = {}
        data.noise = {}
        data.map = {}
        data.land = {}

        make_rand_vectors()
        calculate_noise_coefficients()
        sample_distortion_map()

        data.pattern = pattern.create()
        return data
    end
    
    local function reload(d)
        data = d
        pattern.reload(data.pattern)
    end

    local function compute(x, y)
        local dx = 0
        local dy = 0
        for wavelength, amp in pairs(w) do
            if amp > 0 then
                local a = interpolate_map((x + 10000) / wavelength, (y + 10000) / wavelength)
                dx = dx + a[1] * wavelength * amp
                dy = dy + a[2] * wavelength * amp
            end
        end
        return pget(x + dx, y + dy)
        -- local a = interpolate_map(x / l, y / l)
        -- return pget(x + a[1] * l, y + a[2] * l)
        -- local a = compute_map(x / l, y / l)
        -- return pget(x + a[1] * l, y + a[2] * l)
    end

    local function key(x, y)
        return x .. '#' .. y
    end

    local function geti(x, y)
        local k = key(x, y)
        if data.land[k] == nil then
            data.land[k] = compute(x, y)
        end
        return data.land[k]
    end

    local function get(x, y)
        return geti(math.floor(x + 0.5), math.floor(y + 0.5))
    end

    return {
        create = create,
        reload = reload,
        get = get,
        lua = 'Distort(' .. pattern.lua .. ', ' .. w_str .. ')'
    }
end
