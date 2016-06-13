-- perf
local setmetatable = setmetatable
local cache = LoadV('vanilla.v.libs.cache')

local Response = {}
Response.__index = Response

function Response:new()
    local instance = {
        headers = {},
        append_body = '',
        body = '',
        prepend_body = '',
        page_cache_timeout = 1000,
    }
    setmetatable(instance, Response)
    return instance
end

function Response:appendBody(append_body)
    if append_body ~= nil and type(append_body) == 'string' then
        self.append_body = append_body
    else
        error({ code = 105, msg = {AppendBodyErr = 'append_body must be a not empty string.'}})
    end
end

function Response:clearBody()
    self.body = nil
end

function Response:clearHeaders()
    for k,_ in pairs(ngx.header) do
        ngx.header[k] = nil
    end
end

function Response:getBody()
    return self.body
end

function Response:getHeader()
    return self.headers
end

function Response:prependBody(prepend_body)
    if prepend_body ~= nil and type(prepend_body) == 'string' then
        self.prepend_body = prepend_body
    else
        error({ code = 105, msg = {PrependBodyErr = 'prepend_body must be a not empty string.'}})
    end
end

function Response:response()
    local vanilla_version = Registry['VANILLA_VERSION']
    ngx.header['Power_By'] = 'Vanilla-' .. vanilla_version
    ngx.header['Content_type'] = ngx.header['Content_type'] or 'text/html'
    local body = {[1]=self.append_body, [2]=self.body, [3]=self.prepend_body}
    local rs = table.concat( body, "")
    ngx.print(rs)
    if Registry['APP_PAGE_CACHE'] then
        local cache_lib = Registry['VANILLA_CACHE']
        local page_cache = cache_lib()
        page_cache:set(Registry['REQ_URI'], rs, self.page_cache_timeout)
    end
    return true
end

function Response:setPageCacheTimeOut(timeout)
    local timeout = timeout or 1000
    self.page_cache_timeout = timeout
end

function Response:setBody(body)
    if body ~= nil then self.body = body end
end

function Response:setStatus(status)
    if status ~= nil then ngx.status = status end
end

function Response:setHeaders(headers)
    if headers ~=nil then
        for header,value in pairs(headers) do
            ngx.header[header] = value
        end
    end
end

function Response:setHeader(key, value)
    ngx.header[key] = value
end

return Response