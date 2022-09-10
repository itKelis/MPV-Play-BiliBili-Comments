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
	-- get video cid
	local cid = mp.get_opt('cid')
	if (cid == nil)
	then
		return
	end
	
	local python_path = 'python' -- path to python bin

	-- get script directory 
	local directory = mp.get_script_directory()
	local py_path = ''..directory..'\\Danmu2Ass.py'

	-- under windows platform, convert path format
	if string.find(directory, "\\")
	then
		string.gsub(directory, "/", "\\")
		py_path = ''..directory..'/Danmu2Ass.py'
	end
	
	-- choose to use python or .exe
	local arg = { 'python', py_path, '-d', directory, cid}
	-- local arg = { ''..directory..'\\Danmu2Ass.exe', '-d', directory, cid}
	log('弹幕正在上膛')
	-- run python to get comments
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = arg,
		capture_stdout = true
	},function(res, val, err)
		if err == nil
		then
			log('开火')
			mp.set_property_native("options/sub-file-paths", directory)
			mp.set_property('sub-auto', 'all')
			mp.command('sub-reload')
			mp.commandv('rescan_external_files','reselect')
		else
			log(err)
		end
	end)

end


mp.add_key_binding('b',	assert)
mp.register_event("start-file", assert)
