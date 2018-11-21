local config = require("lapis.config")

-- config("production", {
--   for k,v in pairs json_file "etc/config.json"
--     set k, v
--     })

--  config("development", {
-- 	for k,v in pairs json_file "etc/config.json"
--     	set k, v
--  })

config("development", {
	port = 80,
	lua_code_cache = on,
	num_workers = 8
})

config("production",{ 
	port = 80,
	lua_code_cache = on
})