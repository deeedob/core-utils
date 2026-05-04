-- Guard against API mismatches between plugin versions and yazi versions.
-- Run `ya pkg upgrade` if the git plugin fails to load.
local ok, git = pcall(require, "git")
if ok then
	git:setup { order = 1500 }
end

-- Relative vim-style motions (3j, 5k, 2gg, …).
-- show_numbers = "relative" draws relative line numbers in the file panel.
-- show_motion  = true shows the accumulated count in the status bar.
local ok_rm, rm = pcall(require, "relative-motions")
if ok_rm then
	rm:setup { show_numbers = "relative", show_motion = true, enter_mode = "first" }
end

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	time = time == 0 and "" or os.date("%d.%m %H:%M", time)

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
