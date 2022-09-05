-- assert lua script
-- ===================|
-- note to escape path for winodws (c:\\users\\user\\...)

local utils = require 'mp.utils'

-- Log function: log to both terminal and MPV OSD (On-Screen Display)
function log(string,secs)
	secs = secs or 2.5
	mp.msg.warn(string)
	mp.osd_message(string,secs)
end

-- download/load function
function assert()
	local cid = mp.get_opt('cid')
	if (cid == nil)
	then
		return
	end
	local python_path = 'python' -- path to python bin
	-- log('弹幕正在上膛')

	-- get script directory and comment cid
	local directory = mp.get_script_directory()
	local cid = mp.get_opt('cid')

	-- under windows platform, convert path format
	if string.find(directory, "\\")
	then
		string.gsub(directory, "/", "\\")
	end
	
	local py_path = ''..directory..'\\Danmu2Ass.py'
	
	-- choose to use python or .exe
	local arg = { 'python', py_path, '-d', directory, cid}
	-- local arg = { ''..directory..'\\Danmu2Ass.exe', '-d', directory, cid}
	
	-- run python to get comments
	local result = mp.command_native({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = arg,
	})
	-- log(result.stdout)
	
	-- when download is done, load subs
	if string.find(result.stdout, 'done') then
		log('开火!')
		mp.set_property_native("options/sub-file-paths", directory)
		mp.set_property('sub-auto', 'all')
		mp.command('sub-reload')
		mp.commandv('rescan_external_files','reselect')
	else
		log('哎呀弹幕丢失了，请检查网络或代码')
	end
end

mp.add_key_binding('b',assert)
mp.register_event("start-file", assert)
