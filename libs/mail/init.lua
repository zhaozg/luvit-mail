local M = {}

M.smtp = require('./smtp')
M.mime = require('./mime')

M.ltn12 = require('./ltn12')
local smtp = M.smtp

M.message = smtp.message
M.send = function(mailt,callback)
  local client = smtp:new()
  client:open(mailt.port or 25, mailt.server or '127.0.0.1', function()
    if type(mailt.message)=='table' then
      mailt.source = mailt.source or smtp.message(mailt.message)
    end
    client:send(mailt)
  end)
  client:on('done',callback)
  client:on('error',function(err,message)
    callback(err,message)
  end)
end

return M
