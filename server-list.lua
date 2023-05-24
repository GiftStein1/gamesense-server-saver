local label1 = ui.new_label("LUA", "B","-----------------------------------------------------------")
local ip_port_label = ui.new_label("LUA", "B","IP:Port")
local ip_port_entry = ui.new_textbox("LUA", "B","IP:Port", "IP:PORT", function(ip_port) end)

local name_label = ui.new_label("LUA", "B", "Name")
local name_entry = ui.new_textbox("LUA", "B","Name", "Name", function(name) end)

local delete_mode_checkbox = ui.new_checkbox("LUA", "B", "Delete Mode")

local buttons = {}
local button_visibility = {}

local function delete_server(name)
    local servers = database.read("servers")
    if servers then
        servers[name] = nil
        database.write("servers", servers)
        button_visibility[name] = false
    end
end

local function create_server_button(name, ip_port)
    buttons[name] = ui.new_button("LUA", "B", name, function()
        if ui.get(delete_mode_checkbox) then
            delete_server(name)
            ui.set_visible(buttons[name], false)
            buttons[name] = nil
        else
            client.exec("connect " .. ip_port)
        end
    end)
    if button_visibility[name] == false then
        ui.set_visible(buttons[name], false)
    end
end

local confirm_button = ui.new_button("LUA", "B","Confirm", function()
    local ip_port = ui.get(ip_port_entry)
    local name = ui.get(name_entry)

    if ip_port and name then
        local servers = database.read("servers") or {}
        servers[name] = ip_port
        database.write("servers", servers)
        button_visibility[name] = true

        create_server_button(name, ip_port)
    end
end)

local function load_servers()
    print("Starting load_servers")

    local servers = database.read("servers")
    if not servers then
        print("Creating new server list")
        database.write("servers", {})
        return
    end

    for name, ip_port in pairs(servers) do
        create_server_button(name, ip_port)
    end

    print("Finished load_servers")
end

load_servers()
