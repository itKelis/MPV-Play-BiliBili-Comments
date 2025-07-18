-- https://github.com/itKelis/MPV-Play-BiliBili-Comments

local mp = require 'mp'
local utils = require 'mp.utils'
local options = require 'mp.options'

local o = {
	--自动显示弹幕
	autoplay = true,
	--最小弹幕数量
	mincount = 1,
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
	--在osd显示日志
	log_osd = false,
	--使用Danmu2Ass.py，为false时使用Danmu2Ass.exe
	use_python = true,
	-- python可执行文件路径，默认为环境变量的python，若无法运行请指定 python[.exe] 的路径
	python_path = "python",
}

options.read_options(o)

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
local function log(string, secs)
	mp.msg.info(string)

	if o.log_osd then
		secs = secs or 2.5
		mp.osd_message(string, secs)
	end
end

-- load function
local function load_danmu(file)
	if not file_exists(file) then return end
	mp.set_property_native("secondary-sub-visibility", false)
	mp.set_property_native("secondary-sub-ass-override", false)
	mp.commandv("sub-add", file, "auto")
	local sub_count = get_sub_count()
	mp.set_property_native("secondary-sid", sub_count)
	local approximatedDanmukuCount = math.floor((utils.file_info(file)["size"] - 850) / 120)
	log(file ..
		' [' .. utils.file_info(file)["size"] ..
		'][' .. approximatedDanmukuCount .. ']')
	if o.autoplay and approximatedDanmukuCount >= o.mincount then
		Danmaku_show()
	end
end

-- check danmaku exist, if true, load it
local function Danmaku_check()
	local cid = mp.get_opt('cid')

	if cid == nil then
		local path = mp.get_property("path")
		if path and not path:find('^%a[%w.+-]-://') and not (path:find('bilibili.com') or path:find('bilivideo.com')) then
			return
		end

		local danmaku_id = nil
		cid, danmaku_id = get_cid()

		if danmaku_id ~= nil then
			mp.commandv('sub-remove', danmaku_id)
		end
	end

	mp.set_property_native("sid", false)

	Danmaku_process(cid)
end

-- call Danmu2Ass executable
function Danmaku_process(cid)
	if cid == nil then return end

	-- get danmaku directory
	local danmaku_dir = os.getenv("TEMP") or "/tmp/"
	-- get script directory
	local directory = mp.get_script_directory()
	local py_path = utils.join_path(directory, 'Danmu2Ass.py')
	local exe_path = utils.join_path(directory, 'Danmu2Ass.exe')

	-- no need to convert forwardslashes and backslashes

	local dw = 1920
	local dh = 1080
	local aspect = mp.get_property_number('width', 16) / mp.get_property_number('height', 9)
	if aspect > dw / dh then
		dh = math.floor(dw / aspect)
	elseif aspect < dw / dh then
		dw = math.floor(dh * aspect)
	end
	-- choose to use python or .exe
	local arg = nil
	if o.use_python then
		arg = {
			o.python_path, py_path,
			'-d', danmaku_dir,
			'-s', '' .. dw .. 'x' .. dh,
			'-fn', o.fontname,
			'-fs', o.fontsize,
			'-a', o.opacity,
			'-dm', o.duration_marquee,
			'-ds', o.duration_still,
			'-flf', mp.command_native({ "expand-path", o.filter_file }),
			'-p', tostring(math.floor(o.percent * dh)),
			'-r', cid,
		}
	else
		arg = {
			exe_path,
			'-d', danmaku_dir,
			'-s', '' .. dw .. 'x' .. dh,
			'-fn', o.fontname,
			'-fs', o.fontsize,
			'-a', o.opacity,
			'-dm', o.duration_marquee,
			'-ds', o.duration_still,
			'-flf', mp.command_native({ "expand-path", o.filter_file }),
			'-p', tostring(math.floor(o.percent * dh)),
			'-r', cid,
		}
	end

	-- run python to get comments
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = arg,
	}, function(res, val, err)
		if err == nil
		then
			danmu_file = utils.join_path(danmaku_dir, 'bilibili.ass')
			load_danmu(danmu_file)
		else
			log("处理错误: " .. err)
		end
	end)
end

-- toggle danmaku visibility
function Danmaku_toggle()
	if not danmu_file then return end

	if danmu_open then
		Danmaku_unshow()
		return
	end

	if not danmu_open and mp.get_property_native('secondary-sid') then
		Danmaku_show()
	end
end

-- remove danmaku
function Danmaku_terminate()
	if not danmu_file then return end
	log('文件结束')
	if file_exists(danmu_file) then
		os.remove(danmu_file)
	end
	danmu_file = nil
	danmu_open = false
	mp.set_property_native("secondary-sub-visibility", sec_sub_visibility)
	mp.set_property_native("secondary-sub-ass-override", sec_sub_ass_override)
	mp.commandv('vf', 'remove', '@60FPS')
end

-- hide danmaku
function Danmaku_unshow()
	log('隐藏弹幕')
	danmu_open = false
	mp.set_property_native("secondary-sub-visibility", false)
	mp.commandv('vf', 'remove', '@60FPS')
end

-- show danmaku
function Danmaku_show()
	log('显示弹幕')
	danmu_open = true
	mp.set_property_native("secondary-sub-visibility", true)
	if mp.get_property_number("container-fps", 30) < 45 then
		mp.commandv('vf', 'append', '@60FPS:lavfi="fps=fps=60:round=down"')
	end
end

mp.add_key_binding(nil, 'tdanmu', Danmaku_toggle)
mp.register_event("file-loaded", Danmaku_check)
mp.register_event("end-file", Danmaku_terminate)
mp.register_script_message('load-danmaku', Danmaku_process)
