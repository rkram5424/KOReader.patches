local BD = require("ui/bidi")
local util = require("util")

local userpatch = require("userpatch")
local logger = require ("logger")

local function patchCoverBrowser(plugin)
    local ptutil = require("ptutil")
    function ptutil.formatTags(keywords, tags_limit)
        if not keywords or keywords == "" then return nil end
        local final_tags_list = {}
        local full_list = util.splitToArray(keywords, "\n")

        -- If no newlines found, try splitting by comma (for PDF metadata)
        if #full_list == 1 and keywords:find(",") then
            full_list = util.splitToArray(keywords, ",")
        end

        local nb_tags = #full_list
        if nb_tags == 0 then return nil end
        tags_limit = tags_limit or 9999
        for i = 1, math.min(tags_limit, nb_tags) do
            local t = full_list[i]
            if t and t ~= "" then
                table.insert(final_tags_list, BD.auto(util.trim(t)))
            end
        end
        local formatted_tags = table.concat(final_tags_list, ptutil.separator.bullet)
        if nb_tags > tags_limit then
            formatted_tags = formatted_tags .. "…"
        end
        return formatted_tags
    end
end

userpatch.registerPatchPluginFunc("coverbrowser", patchCoverBrowser)
