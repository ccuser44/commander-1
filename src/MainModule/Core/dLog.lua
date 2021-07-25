local DEBUG_MODE = true
local LOG_CONTEXTS = {
    ["Wait"] = "Commander; ⏳ %s",
    ["Warn"] = "Commander; ⚠️ %s",
    ["Success"] = "Commander; ✅ %s",
    ["Error"] = "Commander; 🚫 %s",
    ["Confusion"] = "Commander; 🤷🏻‍♂️ %s",
    ["Info"] = "Commander; ℹ️ %s"
}

return function(context, ...)
    if DEBUG_MODE then
        if LOG_CONTEXTS[context] then
            if context == "Error" then
                error(string.format(LOG_CONTEXTS[context], ...))
            elseif context == "Warn" then
                warn(string.format(LOG_CONTEXTS[context], ...))
            else
                print(string.format(LOG_CONTEXTS[context], ...))
            end
        end
    end
end