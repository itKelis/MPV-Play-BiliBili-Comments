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
function assprocess()
	-- get video cid
	local cid = mp.get_opt('cid')
	if (cid == nil)
	then
		return
	end
	
	local python_path = 'python' -- path to python bin

	-- get script directory 
	local directory = mp.get_script_directory()
	local py_path = ''..directory..'/Danmu2Ass.py'

	-- under windows platform, convert path format
	if string.find(directory, "\\")
	then
		string.gsub(directory, "/", "\\")
		py_path = ''..directory..'\\Danmu2Ass.py'
	end
	
	-- choose to use python or .exe
	local arg = { 'python', py_path, '-d', directory, 
	-- 设置屏幕分辨率 （默认 1920x1080)
	'-s', '1920x1080',
	-- 设置字体大小    (默认 37.0)
	'-fs',  '37.0',
	-- 设置弹幕不透明度 (默认 0.95)
	'-a', '0.95',
	-- 滚动弹幕显示的持续时间 (默认 10秒)
	'-dm', '10.0',
	-- 静止弹幕显示的持续时间 (默认 5秒)
	'-ds', '5.0',
	-- 保留底部多少高度的空白区域 (默认　０, 取值0.0-1.0)
	'-p', '0',
	'-r',
	cid,
}
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


mp.add_key_binding('b',	assprocess)
mp.register_event("start-file", assprocess)
