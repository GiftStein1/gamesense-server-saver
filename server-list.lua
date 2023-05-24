local io = require "file"

local label1 = ui.new_label("LUA", "B","-----------------------------------------------------------")
local ip_port_label = ui.new_label("LUA", "B","IP:Port")
local ip_port_entry = ui.new_textbox("LUA", "B","IP:Port", "IP:PORT", function(ip_port) end)

local name_label = ui.new_label("LUA", "B", "Name")
local name_entry = ui.new_textbox("LUA", "B","Name", "Name", function(name) end)

local function create_server_button(name, ip_port)
    ui.new_button("LUA", "B", name, function()
        client.exec("connect " .. ip_port)
    end)
end

local confirm_button = ui.new_button("LUA", "B","Confirm", function()
    local ip_port = ui.get(ip_port_entry)
    local name = ui.get(name_entry)

    if ip_port and name then
        local file = io.open("server_list.txt", "a")
        file:write(name .. ": " .. ip_port .. "\n")
        file:close()

        create_server_button(name, ip_port)
    end
end)

local function load_servers()
    print("Starting load_servers")

    local file, err = io.open("server_list.txt", "r")
    
    if not file then
        print("Creating new server_list.txt")
        local newFile = io.open("server_list.txt", "w")
        newFile:close()
        return
    end

    local content = file:read("*all")
    if content == "" then
        print("Empty server_list.txt")
        file:close()
        return
    end

    file:seek("set", 0)
    print("Reading server_list.txt")

    local content = file:read("*all")
    file:close()
    for line in content:gmatch("(.-)\n") do
        local name, ip_port = string.match(line, "(.-): (.+)")
        if name and ip_port then
            create_server_button(name, ip_port)
        end
    end
    

    file:close()
    print("Finished load_servers")
end


load_servers()
