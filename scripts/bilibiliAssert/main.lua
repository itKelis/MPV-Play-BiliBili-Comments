-- assert lua script
-- ===================|
-- note to escape path for winodws (c:\\users\\user\\...)

local utils = require 'mp.utils'
local options = require 'mp.options'

local o = {
	--弹幕字体
	fontname = "sans-serif",
	--弹幕字体大小 
	fontsize = "50",
	--弹幕不透明度(0-1)
	opacity = "0.95",
	--滚动弹幕显示的持续时间 (秒)
	duration_marquee = "10",
	--静止弹幕显示的持续时间 (秒)
	duration_still = "5",
	--保留底部多少高度的空白区域 (取值0.0-1.0)
	percent = "0.75",
	--弹幕屏蔽的关键词文件路径，支持绝对和相对路径
	filter_file = "",
	-- python可执行文件路径，默认为环境变量的python，若无法运行请指定 python[.exe] 的路径
	python_path = "python",
}

options.read_options(o, _, function() end)

local danmu_file = nil
local danmu_open = false
local sec_sub_visibility = mp.get_property_native("secondary-sub-visibility")
local sec_sub_ass_override = mp.get_property_native("secondary-sub-ass-override")

local function get_cid()
	local cid, danmaku_id = nil, nil
	local tracks = mp.get_property_native("track-list")
	for _, track in ipairs(tracks) do
		if track["lang"] == "danmaku" then
			cid = track["external-filename"]:match("/(%d-)%.xml$")
			danmaku_id = track["id"]
			break
		end
	end
	return cid, danmaku_id
end

local function get_sub_count()
	local count  = 0
	local tracks = mp.get_property_native("track-list")
	for _, track in ipairs(tracks) do
		if track["type"] == "sub" then
			count = count + 1
		end
	end
	return count
end

local function file_exists(path)
	if path then
		local meta = utils.file_info(path)
		return meta and meta.is_file
	end
	return false
end

-- Log function: log to both terminal and MPV OSD (On-Screen Display)
local function log(string,secs)
	secs = secs or 2.5
	mp.msg.warn(string)
	mp.osd_message(string,secs)
end

-- load function
local function load_danmu(danmu_file)
	if not file_exists(danmu_file) then return end
	log('开火')
	danmu_open = true
	-- 如果可用将弹幕挂载为次字幕
	if sec_sub_ass_override then
		mp.commandv("sub-add", danmu_file, "auto")
		local sub_count = get_sub_count()
		mp.set_property_native("secondary-sub-ass-override", "yes")
		mp.set_property_native("secondary-sid", sub_count)
		mp.set_property_native("secondary-sub-visibility", true)
	else
		-- 挂载subtitles滤镜，注意加上@标签，这样即使多次调用也不会重复挂载，以最后一次为准
		mp.commandv('vf', 'append', '@danmu:subtitles=filename="'..danmu_file..'"')
		-- 只能在软解或auto-copy硬解下生效，统一改为auto-copy硬解
		mp.set_property('hwdec', 'auto-copy')
	end
end

-- download function
local function assprocess()
	local path = mp.get_property("path")
	if path and not path:find('^%a[%w.+-]-://') and not (path:find('bilibili.com') or path:find('bilivideo.com'))
	then return end
	-- check if filepahth to python exist
	if not o.python_path == "python" and not file_exists(o.python_path) then
		log('未找到 Python 可执行文件: ' .. o.python_path)
		return
	end
	-- get video cid
	local cid = mp.get_opt('cid')
	if cid == nil and path and path:find('^%a[%w.+-]-://') then
		cid, danmaku_id = get_cid()
		if danmaku_id ~= nil then
			mp.commandv('sub-remove', danmaku_id)
		end
	end
	if cid == nil then return end

	-- get danmaku directory
	local danmaku_dir = os.getenv("TEMP") or "/tmp/"
	-- get script directory
	local directory = mp.get_script_directory()
	local py_path = utils.join_path(directory, 'Danmu2Ass.py')

	-- under windows platform, convert path format
	if string.find(directory, "\\")
	then
		string.gsub(directory, "/", "\\")
		py_path = ''..directory..'\\Danmu2Ass.py'
	end
	local dw = "1920"
	local dh = "1080"
	local aspect = mp.get_property_number('width', 16) / mp.get_property_number('height', 9)
	if aspect > dw / dh then
		dh = math.floor(dw / aspect)
	elseif aspect < dw / dh then
		dw = math.floor(dh * aspect)
	end
	-- choose to use python or .exe
	local arg = { o.python_path, py_path, '-d', danmaku_dir, 
	'-s', ''..dw..'x'..dh,
	'-fn', o.fontname,
	'-fs',  o.fontsize,
	'-a', o.opacity,
	'-dm', o.duration_marquee,
	'-ds', o.duration_still,
	'-flf', mp.command_native({ "expand-path", o.filter_file }),
	'-p', tostring(math.floor(o.percent*dh)),
	'-r',
	cid,
	}
	-- local arg = { ''..directory..'\\Danmu2Ass.exe', '-d', danmaku_dir, 
	-- '-s', ''..dw..'x'..dh,
	-- '-fn', o.fontname,
	-- '-fs',  o.fontsize,
	-- '-a', o.opacity,
	-- '-dm', o.duration_marquee,
	-- '-ds', o.duration_still,
	-- '-flf', mp.command_native({ "expand-path", o.filter_file }),
	-- '-p', tostring(math.floor(o.percent*dh)),
	-- '-r',
	-- cid,
	-- }
	log('弹幕正在上膛')
	-- run python to get comments
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = arg,
	},function(res, val, err)
		if err == nil
		then
			danmu_file = utils.join_path(danmaku_dir, 'bilibili.ass')
			load_danmu(danmu_file)
		else
			log(err)
		end
	end)

end

-- toggle function
function asstoggle(event)
	if not file_exists(danmu_file) then return end
	if danmu_open then
		log('停火')
		danmu_open = false
		if sec_sub_ass_override then
			if event then
				mp.set_property_native("secondary-sub-visibility", sec_sub_visibility)
			else
				mp.set_property_native("secondary-sub-visibility", false)
			end
			mp.set_property_native("secondary-sub-ass-override", sec_sub_ass_override)
			return
		elseif sec_sub_ass_override == nil then
			-- if exists @danmaku filter， remove it
			for _, f in ipairs(mp.get_property_native('vf')) do
				if f.label == 'danmu' then
					mp.commandv('vf', 'remove', '@danmu')
					return
				end
			end
		end
	end
	-- otherwise, load danmu
	if not event and file_exists(danmu_file) then
		load_danmu(danmu_file)
	end
end

mp.add_key_binding('b', 'toggle', asstoggle)
mp.register_event("file-loaded", assprocess)
mp.register_event("end-file", function()
	asstoggle(true)
	if file_exists(danmu_file) then
		os.remove(danmu_file)
	end
end)
