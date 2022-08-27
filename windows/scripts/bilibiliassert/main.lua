-- assert lua script
-- ===================|
-- note to escape path for winodws (c:\\users\\user\\...)
local python_path = 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\python' -- path to python bin
local scripts_path = 'C:\\Users\\Administrator\\AppData\\Roaming\\mpv\\scripts' -- path to scripts folder 
local py_path = ''..scripts_path..'\\bilibiliAssert\\convertAss.py' -- don't change this one
local utils = require 'mp.utils'

-- Log function: log to both terminal and MPV OSD (On-Screen Display)
function log(string,secs)
	secs = secs or 2.5
	mp.msg.warn(string)
	mp.osd_message(string,secs)
end

-- download/load function
function assert()
	log('弹幕正在上膛')

	--get directory and filename
	local directory,filename = utils.split_path(mp.get_property('path'))
    local table = { args = { python_path } }
	
	cid = mp.get_opt("cid")
    local a = table.args

	a[#a + 1] = py_path
	a[#a + 1] = '-d'
	a[#a + 1] = mp.get_script_directory()
	a[#a + 1] = cid --> cid get from script

	-- run command and capture stdout
	local result = utils.subprocess(table)
	log(result.stdout)

	if string.find(result.stdout, 'done') then
		log('开火!')
		-- to make sure all downloaded subtitle loaded
		mp.set_property('sub-auto', 'all')
		mp.command('sub-reload')
		mp.commandv('rescan_external_files','reselect')
	else
		log('哎呀弹幕丢失了，请检查网络或代码')
	end
end
mp.add_key_binding('b',assert)
