require("git"):setup {
	order = 1500,
}

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	time = time == 0 and "" or os.date("%d.%m %H:%M", time)

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end
