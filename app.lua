local lapis = require("lapis")
local util = require("lapis.util")
local json_params = require("lapis.application").json_params
local app = lapis.Application()

local upload = require("resty.upload")
local cjson = require("cjson")

local mongorover = require("mongorover")
local client = mongorover.MongoClient.new("mongodb://localhost:27017/")
local database = client:getDatabase("floryday-logs")

local app_helpers = require("lapis.application")
local capture_errors_json, assert_error = app_helpers.capture_errors_json, app_helpers.assert_error

app.handle_error = function ( self, err, trace )
	return {json = "code: -1, msg: "..err..trace}
end

exp = function ( msg )
	print(msg)
end

app:before_filter(function ( self )
	if self.session.user then 
		self.current_user = load_user(self.session.user)
	end

	if self.params.data then
		print(self.params.data)
		local success, data = pcall(util.from_json, self.params.data)
		if success then
			self.data_json = data
		end
		-- print(self.params.data)
		-- self.data_json, err = util.from_json(self.params.data)
	end
end)

app:match("/", capture_errors_json(function ( self )
	yield_error("something bad happened")
end))



-- app:get("/logs", function()
--   return "Welcome to Lapis " .. require("lapis.version")
-- end)


-- 各种排他性日志
app:post("/logs", json_params(function (self)
	local collection = database:getCollection("logs")
	local result = collection:insert_one({data = util.from_json(self.params.data), tag = "logs"})
	
	return {json="{code: 1, msg: '', data : '"..self.params.data.."'}"}
end))


-- 各种error错误栈，包含dump信息
app:post("/error", function ( self )
	print(self.params.data)

	local collection = database:getCollection("errors")
	local result = collection:insert_one({data = self.params.data, tag = "error"})
	
	return {json = "{code:1, msg : 'success'}"}
end)


-- http网络请求日志记录
app:post("/http", function ( self )
	local collection = database:getCollection("http")
	local result = collection:insert_one({data = self.data_json, tag = "http"})

	return {json = "{code: 1, msg : 'success'}"}
end)

app:post("/debug", function ( self )
	local collection = database:getCollection("debug")
	local result = collection:insert_one({data = self.params.data, tag = "debug"})

	return {json = "{code: 1, msg : 'success'}"}
end)

app:post("/performance", function ( self )

	local collection = database:getCollection("performance")
	local result = collection:insert_one({data = self.params.data, tag = "performance"})


	return {json = "{code: 1, msg : 'success'}"}
end)

app:post("/file", function ( self )
	-- print(self.params.file.content)
	-- local collection = database:getCollection("file")
	-- local result = collection:insert_one({data = self.params.file, tag = "file"})
	-- 因为使用了lapis，不能多次读取ngx.req.body 内容
	-- local chunk_size = 8192
	-- local form, err = upload:new(chunk_size)
	-- if not form then
	-- 	print("failed to new upload: ", err)
	-- 	ngx.exit(500)
	-- end

	-- form:set_timeout(1000)
	-- while true do
	-- 	local typ, res, err = form:read()
	-- 	if not typ then
	-- 		print("failed to read: ", err)
	-- 		return
	-- 	end

	-- 	print("read: ", cjson.encode({typ, res}))
	-- 	if typ == "eof" then
	-- 		break
	-- 	end
	-- end

	-- local  typ, res, err = form:read()
	-- print("read: ", cjson.encode({typ, res}))

	return {json = "{code: 1, msg : 'success'}"}
end)



return app
