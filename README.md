Show a desktop notification when the song changes.

## Requirements

`notify-send` has to be installed and available on your `$PATH`. Usually provided by `libnotify`.

## Installation

```lua
rmpcd.install({ url = "https://github.com/rmpc-org/rmpcd-notify.git" })
```

## Configuration

All options are optional, defaults are below.

```lua
---@type NotifyPluginHandle
local notify = rmpcd.install({ url = "https://github.com/rmpc-org/rmpcd-notify.git" })
notify:setup({
    enabled = true,
    -- Show album art in the notification
    with_album_art = true,
    -- Path to cache the current album art, located in XDG_CACHE_HOME or ~/.cache
    album_art_path = os.getenv("HOME") .. "/.cache/rmpcd/notify-album-art",
    -- Where a fallback album art is located, used in case when the song does not have an album art
    default_album_art_path = nil,
    -- Debounce the notifications so they do not spam you when quickly changing songs. Set to 0 to
    -- disable.
    debounce_delay = 1000,
})
```

Album art is determined in order of:

- Image embedded in file
- `cover.{png|jpg|webp}` in the song's directory
- Image at `default_album_art_path`
- No image

## Runtime control

Notifications can be turned on and off without restarting rmpcd by sending a message to the
`rmpcd.notify` channel, for example with rmpc:

```sh
rmpc sendmessage rmpcd.notify disable
rmpc sendmessage rmpcd.notify enable
rmpc sendmessage rmpcd.notify toggle
```
