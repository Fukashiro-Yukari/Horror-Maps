Horror.__mapfunc = {}

function Horror.AddMapFunc(n,f)
    if !isstring(n) or !isfunction(f) then return end

    Horror.__mapfunc[n] = f
end

function Horror.CallMapFunc(n)
    if !Horror.__mapfunc[n] then return end

    Horror.__mapfunc[n](ACTIVATOR,CALLER,TRIGGER_PLAYER,LUARUN)
end