---@meta

---@class NotifyArgs
---@field enabled? boolean Whether notifications are on when rmpcd starts. Default true.
---@field with_album_art? boolean Show the song's album art as the notification icon. Default true.
---@field album_art_path? string Where the album art is written so notify-send can pick it up. Default "$XDG_CACHE_HOME/rmpcd/notify-album-art", or "$HOME/.cache/rmpcd/notify-album-art" when XDG_CACHE_HOME is unset or not absolute.
---@field default_album_art_path? string What album art to display in case the song does not have one.
---@field debounce_delay? integer Milliseconds to wait after a song change before notifying. Set to 0 to disable the delay. Default 1000.

---@class NotifyPlugin: RmpcdPlugin<NotifyArgs>
---@field enabled boolean
---@field with_album_art boolean
---@field album_art_path string
---@field default_album_art_path string | nil

---@alias NotifyPluginHandle RmpcdPluginHandle<NotifyArgs>

local M = {}
return M
