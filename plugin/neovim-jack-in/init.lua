local options = {
  -- clj dependencies
  clj_dependencies = {
    { name = "nrepl/nrepl",       version = "RELEASE" },
    { name = "cider/cider-nrepl", version = "RELEASE" },
  },
  -- clj middleware
  clj_middleware = {
    "cider.nrepl/cider-middleware"
  },
  -- leiningen plugins
  lein_plugins = {
    { name = "cider/cider-nrepl", version = "RELEASE" },
  },
  -- buffer, background, vsplit, split, tab
  location = 'background',
}

local is_powershell = vim.o.shell == 'powershell.exe'

-- windows needs to add quotes for powershell because well powershell...
local function version_escape(version)
  if is_powershell == true then
    return '""' .. version .. '""'
  end
  return '"' .. version .. '"'
end

local function map_clj_deps_to_string()
  local string = ''
  for _, v in pairs(options.clj_dependencies) do
    string = string .. v.name .. ' {:mvn/version ' .. version_escape(v.version) .. '} '
  end
  return string
end

local function map_clj_middleware_to_string()
  local string = ''
  for _, v in pairs(options.clj_middleware) do
    string = string .. '"' .. v .. '" '
  end
  return string
end

local clj_string = "clj -Sdeps " ..
    "'{:deps {" ..
    map_clj_deps_to_string() ..
    "}}' " .. "-M -m nrepl.cmdline --middleware '[" .. map_clj_middleware_to_string() .. "]' --interactive"

local function map_lein_plugins_to_string()
  local string = ''
  for _, v in pairs(options.lein_plugins) do
    string = string .. v.name .. ' ' .. version_escape(v.version) .. ' '
  end
  return string
end

local lein_string = "lein update-in :plugins conj '[" .. map_lein_plugins_to_string() .. "]' -- repl"

local function jack_in(execution_string)
  if options.location == "vsplit" then
    vim.cmd('vsplit')
  elseif options.location == "split" then
    vim.cmd('split')
  elseif options.location == "tab" then
    vim.cmd('tabnew')
  end

  vim.cmd(':term ' .. execution_string)
  if options.location == 'background' then
    -- swap to the previous buffer if available
    vim.cmd('bp')
  end
end

vim.api.nvim_create_user_command(
  'Clj', function()
    jack_in(clj_string)
  end,
  {}
)

vim.api.nvim_create_user_command(
  'Lein', function()
    jack_in(lein_string)
  end,
  {}
)
