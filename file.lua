local io = {}

function io.open(filename, mode)
    local file = {
        mode = mode,
        position = 1,
    }

    if mode:match("r") or mode:match("a") or mode:match("w") or mode:match("rb") or mode:match("wb") or mode:match("ab") then
        file.content = readfile(filename) or ""
    end

    if mode:match("w") or mode:match("wb") then
        file.content = ""
    end

    function file:read(format)
        if not self.mode:match("r") and not self.mode:match("rb") then
            error("File is not readable.")
        end
    
        local startPos = self.position
        local endPos
    
        if format == "*all" or format == "*a" then
            endPos = #self.content
        elseif format == "*n" then
            local num = tonumber(self.content:match("%d+", startPos))
            return num
        elseif format == "*l" then
            endPos = self.content:find("\n", startPos) or #self.content
        elseif type(format) == "number" and self.mode:match("rb") then
            endPos = startPos + format - 1
        elseif format == "*b" then
            local byteArray = {}
            for i = 1, #self.content do
                byteArray[i] = string.byte(self.content, i)
            end
            return byteArray
        else
            error("Invalid format. : [\""..format.."\"]")
        end
    
        local result = self.content:sub(startPos, endPos)
        self.position = endPos + 1
        return result
    end    

    function file:write(str)
        if not self.mode:match("w") and not self.mode:match("a") and not self.mode:match("wb") and not self.mode:match("ab") then
            error("File is not writable.")
        end

        if self.mode:match("a") or self.mode:match("ab") then
            self.position = #self.content + 1
        end

        local startPos = self.position
        local endPos = self.position + #str - 1

        self.content = self.content:sub(1, startPos - 1) .. str .. self.content:sub(endPos + 1)
        self.position = endPos + 1
    end

    function file:flush()
        if not self.mode:match("w") and not self.mode:match("a") and not self.mode:match("wb") and not self.mode:match("ab") then
            error("File is not writable.")
        end
        writefile(filename, self.content)
    end

    function file:seek(whence, offset)
        if whence == "set" then
            self.position = offset + 1
        elseif whence == "cur" then
            self.position = self.position + offset
        elseif whence == "end" then
            self.position = #self.content + 1 + offset
        else
            error("Invalid whence.")
        end

        if self.position < 1 then
            self.position = 1
        elseif self.position > #self.content + 1 then
            self.position = #self.content + 1
        end

        return self.position - 1
    end
    
    function file:lines()
        return function()
            local line = self:read("*l")
            if not line then
                file:close()
            end
            return line
        end
    end

    function file:close()
        if self.mode:match("w") or self.mode:match("a") or self.mode:match("wb") or self.mode:match("ab") then
            self:flush()
        end
    end

    return file
end

function io.lines(filename)
    local file = io.open(filename, "r")
    return function()
        local line = file:read("*l")
        if not line then
            file:close()
        end
        return line
    end
end

function io.write(...)
    local args = {...}
    local str = table.concat(args)
    if not output then
        output = io.open("output.txt", "w")
    end
    print(str)
    output:write(str)
end

function io.read(format)
    if not input then
        input = io.open("input.txt", "r")
    end
    format = format or "*l"
    return input:read(format)
end

function io.close()
    if output then
        output:close()
        output = nil
    end
end

return io