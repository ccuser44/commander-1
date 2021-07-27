# Plugins
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
local package = {
    Name = "Plugin",
    Description = "Plugin Description",
    Author = "User",
    Class = "Plugin",
    Target = {}
}

function package.Target:Init()

end

return package
```

It is also recommended to add the above code as a code snippet for future use.

For plugins, Commander will call `:Init()` once all loading for packages has been complete, this includes injecting the necessary dependencies. If your plugin have to require dependencies found in the `Core` folder, but not in the `Preloaded` folder, it is a better idea to initialize those dependencies within the `:Init()` function, and assign them into the `package.Target` table.

A plugin is not necessary to expose methods, a plugin can be a piece of `run-once` code. Plugins are injected automatically into the **commands** only, if you are attempting to adjust the API inside a plugin, it is best to look at the API documentation to see is there a suitable API method.

## Using injected dependencies
Commander by default injects 4 dependencies into a plugin -- `Core`, `API`, `Util`, and `Settings`. However, it is worth noting that the Settings dependency is a copied table, changes to it will not be reflected in the actual settings module.

To begin using either one of the dependencies, use the line `package.Dependency`, where `Dependency` is the name of the dependency, and `package` is the package table (Not to be confused with the package target table).

## Examples
=== "API Checker"
    A checker is a function that validates the user to determine whether the user is an administrator, and which group do they belong to. Luckily, the API has exposed a method to assign a new checker, which is `API.addChecker` ([read more](./api.md#apiaddchecker)).

    First, create a package and use the standard format above

    ```lua
    local package = {
        Name = "Checker",
        Description = "Plugin Description",
        Author = "User",
        Class = "Plugin",
        Target = {}
    }

    function package.Target:Init()

    end

    return package
    ```

    Administration groups and assignee data can be found in the configuration module, which can be required via `package.Core.Settings`, you should initialize settings within the `:Init()` function.

    ```lua

    function package.Target:Init()
        package.Target.Settings = require(package.Core.Settings)
    end

    ```

    Now, we have to write the checker function, in this sitution, let's assume that you want to give everyone the highest administration group in the checker. It is not needed to follow this format for the checker, but it is recommended to do so, to maintain consistency within the ecosystem.

    Administration groups configuration can be accessed via `Settings.Groups`, where assignee data can be found in `Settings.Permissions`. The format of a group and assignee configuration can be found in [this page](./settings.md)

    A checker is expected to return an integer, which should be the index of the group configuration, inside the groups configuration table.

    ```lua

    function package.Target.onInvoke()
        return #package.Target.Settings.Groups -- This will give everyone the highest group
    end

    ```

    Now, once you are done writing the checker, make it so the API will load the checker, with the method `API.addChecker`

    ```lua

    function package.Target:Init()
        package.Target.Settings = require(package.Core.Settings)
        package.API.addChecker(package.Target.onInvoke)
    end

    ```

    That's all. :tada: