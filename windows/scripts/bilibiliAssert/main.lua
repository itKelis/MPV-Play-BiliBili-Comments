-- assert lua script
-- ===================|
-- note to escape path for winodws (c:\\users\\user\\...)
local python_path = 'python' -- path to python bin
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
	local directory = mp.get_script_directory()
	local cid = mp.get_opt("cid")
	local table = { args = { python_path } }
 
	local a = table.args
	
	if string.find(directory, "\\")
	then
		string.gsub(directory, "/", "\\")
	end

	local py_path = ''..directory..'\\convertAss.py'

	a[#a + 1] = py_path
	a[#a + 1] = '-d'
	a[#a + 1] = directory
	a[#a + 1] = cid --> cid get from script

	-- run command and capture stdout
	local result = utils.subprocess(table)
	log(result.stdout)

	if string.find(result.stdout, 'done') then
		log('开火!')
		-- to make sure all downloaded subtitle loaded
		mp.set_property('sub-auto', 'no')
		mp.set_property('sub-auto', 'all')
		mp.command('sub-reload')
		mp.commandv('rescan_external_files','reselect')
	else
		log('哎呀弹幕丢失了，请检查网络或代码')
	end
end
mp.add_key_binding('b',assert)
