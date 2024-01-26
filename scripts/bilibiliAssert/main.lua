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
	local dw = mp.get_property_osd('display-width')
	local dh = mp.get_property_osd('display-height')
	local dw = mp.get_property_number('display-width', 1920)
	local dh = mp.get_property_number('display-height', 1080)
	local aspect = mp.get_property_number('width', 16) / mp.get_property_number('height', 9)
	if aspect > dw / dh then
		dh = math.floor(dw / aspect)
	elseif aspect < dw / dh then
		dw = math.floor(dh * aspect)
	end
	-- 保留底部多少高度的空白区域 (默认0, 取值0.0-1.0)
	local percent = 0.75
	-- choose to use python or .exe
	local arg = { 'python', py_path, '-d', directory, 
	-- 设置屏幕分辨率 （自动取值)
	'-s', ''..dw..'x'..dh,
	-- 设置字体大小    (默认 37.0)
	'-fs',  '37.0',
	-- 设置弹幕不透明度 (默认 0.95)
	'-a', '0.95',
	-- 滚动弹幕显示的持续时间 (默认 10秒)
	'-dm', '10.0',
	-- 静止弹幕显示的持续时间 (默认 5秒)
	'-ds', '5.0',
	'-p', tostring(math.floor(percent*dh)),
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
			-- 挂载subtitles滤镜，注意加上@标签，这样即使多次调用也不会重复挂载，以最后一次为准
			mp.commandv('vf', 'append', '@danmu:subtitles=filename="'..directory..'/bilibili.ass"')
			-- 只能在软解或auto-copy硬解下生效，统一改为auto-copy硬解
			mp.set_property('hwdec', 'auto-copy')
		else
			log(err)
		end
	end)

end

-- toggle function
function asstoggle()
	-- if exists @danmu filter， remove it
	for _, f in ipairs(mp.get_property_native('vf')) do
		if f.label == 'danmu' then
			log('停火')
			mp.commandv('vf', 'remove', '@danmu')
			return
		end
	end
	-- otherwise, load danmu
	assprocess()
end


mp.add_key_binding('b', 'toggle', asstoggle)
mp.register_event("file-loaded", assprocess)
