# Plugin Development

In V2, we have introduced a brand new package system with a new package type called `Plugin`, which is used to extend existing features or add new features to Commander. Those can be UI plugins, API plugins, or plugins used by commands.

In this page, we will walk you through the process of creating a plugin for Commander.

## Preparations

Before building, we need:

- A proper installation of Commander 2.x.x
- Roblox Studio
- Rojo & External Code Editor (Optional)

## Start

To make a plugin recognizable by Commander, you need to ensure the source file has the proper format and declares itself as a `Plugin` package. So, copy and paste the standard package format, which can be found here or in the page about packages in general.

```lua
local packageTarget = {}
local package = {
    Name = "Plugin",
    Description = "Plugin Description",
    Author = "User",
    Class = "Plugin",
    Target = packageTarget
}

function packageTarget:Init()

end

return package
```

It is also recommended to add the above code as a code snippet for future use.

For plugins, Commander will call `:Init()` once all loading for packages has been complete, this includes injecting the necessary dependencies. If your plugin have to require dependencies found in the `Core` folder, but not in the `Preloaded` folder, it is a better idea to initialize those dependencies within the `:Init()` function, and assign them into the `packageTarget` table.

A plugin is not necessary to expose methods, a plugin can be a piece of `run-once` code. Plugins are injected automatically into the **commands** only, if you are attempting to adjust the API inside a plugin, it is best to look at the API documentation to see is there a suitable API method.

## Using injected dependencies

Commander by default injects 4 dependencies into a plugin -- `Core`, `API`, `Util`, and `Settings`. However, it is worth noting that the Settings dependency is a copied table, changes to it will not be reflected in the actual settings module.

To begin using either one of the dependencies, use the line `package.Dependency`, where `Dependency` is the name of the dependency, and `package` is the package table (Not to be confused with the package target table).