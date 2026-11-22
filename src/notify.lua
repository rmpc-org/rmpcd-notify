---@return string
local function get_album_art_path()
    local cache_dir = os.getenv("XDG_CACHE_HOME")
    if cache_dir == nil or cache_dir:sub(1, 1) ~= "/" then
        cache_dir = os.getenv("HOME") .. "/.cache"
    end
    return cache_dir .. "/rmpcd/notify-album-art"
end

---@type NotifyPlugin
---@diagnostic disable-next-line: missing-fields
local M = {}

local notify_send_found = false

---@param uri string
---@param path string
---@return boolean written
local function write_album_art(uri, path)
    local bytes = mpd.read_picture(uri) or mpd.album_art(uri)
    if bytes == nil then
        return false
    end

    local dir = path:match("^(.*)/[^/]*$")
    if dir ~= nil and dir ~= "" then
        local _, dir_err = fs.create_dir_all(dir)
        if dir_err ~= nil then
            log.error("Failed to create album art directory: " .. dir_err)
            return false
        end
    end

    local _, write_err = fs.write(path, bytes)
    if write_err ~= nil then
        log.error("Failed to write album art: " .. write_err)
        return false
    end
    return true
end

---@param self NotifyPlugin
---@param new_song Song
local function notify(self, new_song)
    local title = (new_song.title and new_song.title:first()) or "Unknown Title"
    local body = (new_song.artist and new_song.artist:first()) or "Unknown Artist"
    if new_song.album then
        body = body .. " - " .. new_song.album:first()
    end

    local cmd = {
        "notify-send",
        "--app-name=rmpcd",
        "--hint=string:x-canonical-private-synchronous:rmpcd-notify",
    }

    if self.with_album_art and write_album_art(new_song.file, self.album_art_path) then
        table.insert(cmd, "--icon=" .. self.album_art_path)
    elseif self.with_album_art and self.default_album_art_path ~= nil then
        table.insert(cmd, "--icon=" .. self.default_album_art_path)
    end

    table.insert(cmd, "--")
    table.insert(cmd, title)
    table.insert(cmd, body)

    process.spawn(cmd)
end

---@param _self NotifyPlugin
---@param _new_song Song
local function notify_debounced(_self, _new_song) end

M.setup = function(self, args)
    if not args then
        args = {}
    end
    self.with_album_art = args.with_album_art ~= false
    self.album_art_path = args.album_art_path or get_album_art_path()
    self.enabled = args.enabled ~= false
    self.default_album_art_path = args.default_album_art_path

    notify_send_found = util.which("notify-send")
    if not notify_send_found then
        log.error("notify-send not found in PATH, disabling notify plugin")
        self.enabled = false
    end

    local debounce_delay = args.debounce_delay or 1000
    if debounce_delay <= 0 then
        notify_debounced = notify
    else
        notify_debounced = sync.debounce(debounce_delay, notify)
    end
end

M.song_change = function(self, _old_song, new_song)
    if not self.enabled then
        return
    end

    if new_song == nil then
        return
    end

    notify_debounced(self, new_song)
end

---@param plugin NotifyPlugin
---@param enabled boolean
local function set_enabled(plugin, enabled)
    if enabled and not notify_send_found then
        log.warn("notify-send not found in PATH, notify plugin stays disabled")
        return
    end

    log.info((enabled and "Enabling" or "Disabling") .. " notify plugin")
    plugin.enabled = enabled
end

M.subscribed_channels = { "rmpcd.notify" }
M.message = function(self, _channel, message)
    if message == "enable" then
        set_enabled(self, true)
    elseif message == "disable" then
        set_enabled(self, false)
    elseif message == "toggle" then
        set_enabled(self, not self.enabled)
    end
end

return M
