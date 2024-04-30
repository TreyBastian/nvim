local options = {
  middlewares = {
    { dependency = "cider/cider-nrepl", version = "RELEASE" },
  },
  -- buffer, background, vsplit, split, tab
  location = 'buffer',
  win_use_powershell = true,
  nrepl_version = 'RELEASE',
}

local is_windows = vim.fn.has('win64')

-- windows needs to add quotes for powershell because well windows
local function version_escape(version)
  if is_windows == 1 and options.win_use_powershell == true then
    return '"""' .. version .. '"""'
  end
  return '"' .. version .. '"'
end

local function clj_string()
  -- local string = "clj -Sdeps"
  -- string = string .. vim.fn.shellescape('\'{:deps {nrepl/nrepl {:mvn/version "RELEASE""} ')
  -- for _, v in pairs(options.middlewares) do
  --   string = string .. vim.fn.shellescape(v.dependency .. '{:mvn/version "}' .. v.version .. '""} ')
  -- end
  -- string = string .. vim.fn.shellescape('}}\' ')
  -- string = string .. "--main nrepl.cmdline "
  -- string = string .. "--middleware = '[\"cider.nrepl/cider-middleware\"]'"
  -- string = string .. " --interactive"
  --
  local string =
      "clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version " ..
      version_escape("1.0.0") ..
      "} cider/cider-nrepl {:mvn/version" ..
      version_escape("RELEASE") ..
      "}}}' --main nrepl.cmdline --middleware '[\"cider.nrepl/cider-middleware\"]' --interactive"
  return string
end

local execution_functions = {
  ["buffer"] = "term ",
  ["background"] = "term ",
  ["vsplit"] = "vsplit term://",
  ["split"] = ":split term://",
  ["tab"] = "tabnew term://",
}

local function execute(execution_string)
  local start_string = execution_functions[options.location]

  if options.win_use_powershell == true and is_windows == 1 then
    start_string = start_string .. 'powershell '
  end

  print(start_string .. execution_string)
  vim.cmd(start_string .. execution_string)
  if options.location == 'background' then
    -- swap to the previous buffer if available
    vim.cmd(':bp')
  end
end


function StartClj()
  execute(clj_string())
end

vim.api.nvim_create_user_command(
  'Clj', function()
    StartClj()
  end,
  {}
)
