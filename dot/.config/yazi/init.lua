-- Guard against API mismatches between plugin versions and yazi versions.
-- Run `ya pkg upgrade` if the git plugin fails to load.
local ok, git = pcall(require, "git")
if ok then
	git:setup { order = 1500 }
end

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	time = time == 0 and "" or os.date("%d.%m %H:%M", time)

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
