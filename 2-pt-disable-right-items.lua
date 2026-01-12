--[[
    This user patch is for use with the Project: Title plugin, specifically in the "Cover List" view.

    The Patch removes all right aligned items; progress percent, progress string, finished icons, etc
--]]

local userpatch = require("userpatch")

local function patchCoverBrowser(plugin)
    local listmenu = require("listmenu")
    local ListMenuItem = userpatch.getUpValue(listmenu._updateItemsBuildUI, "ListMenuItem")

    if not ListMenuItem then
        return
    end

    -- Patch the update method to hide right-side items
    local orig_ListMenuItem_update = ListMenuItem.update
    ListMenuItem.update = function(self, ...)
        -- Store original behavior to prevent wright_items from being added
        -- We'll patch the table.insert calls to wright_items by wrapping them

        -- Create a dummy wright_items that discards all insertions
        local _original_table_insert = table.insert
        local in_update = true

        -- Override table.insert temporarily
        table.insert = function(t, ...)
            -- If we're inserting into wright_items (identified by align="right"), skip it
            if in_update and type(t) == "table" and t.align == "right" then
                -- Do nothing - discard the insertion
                return
            else
                -- Normal table.insert for everything else
                return _original_table_insert(t, ...)
            end
        end

        -- Call the original update with all arguments
        local result = orig_ListMenuItem_update(self, ...)

        -- Restore original table.insert
        table.insert = _original_table_insert
        in_update = false

        return result
    end
end

userpatch.registerPatchPluginFunc("coverbrowser", patchCoverBrowser)
