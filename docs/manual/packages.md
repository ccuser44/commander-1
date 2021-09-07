# Packages
Packages are a new feature that allows you to extend or create features for Commander without modifying the internal source code. They can be used as a [command](./commands.md), a [plugin](./plugins.md), or a [stylesheet](./stylesheets.md). 

In this page, we will walk you through the basics of the Commander package system, and the package manager.

## Introduction
Previously in V1, packages are basically commands in a nutshell, simple as that. The use of the term `package` was soemwhat redudant due to its sole usage is as a command only. As a result, we have redefined the definition of packages in V2.

In V2, a package can be a command, a plugin, or a stylsheet. For plugin, it is not neccessary to return anything, it could be just a run-once code to extend or add features. Or modifies a specific module for greater performance or anything else.

## Standard template
```lua
local package = {
    Name = "Name",
    Description = "Description",
    Author = "User",
    Class = "Command/Plugin/Stylesheet",
    Target = {}
}

function package.Target:Init()

end

return package
```

`package.Target:Init()` is available for plugins, they will be called after initalization if it existed.

## Examples
=== "API Checker plugin"
    A checker is a function that validates the user to determine whether the user is an administrator, and which group do they belong to. Luckily, the API has exposed a method to assign a new checker, which is `API.addChecker` ([read more](./api.md#apiaddchecker)).

    First, create a package and use the standard format above

    ```lua
    local package = {
        Name = "Checker",
        Description = "Plugin Description",
        Author = "User",
        Class = "Plugin",
        Category = "Server",
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

=== "Example command"
    A command is used for the administrators to interact with Commander, it could be a command that helps administrators to moderate their game, or as a tool to help with administrators. In this example, we will be writing a simple command which prints out `"Hello World"` upon interaction.

    First, create a package by using the standard format, and fill in the essential information. We will be making this command as a server command.

    ```lua
    local package = {
        Name = "Example",
        Description = "An example command!",
        Author = "User",
        Class = "Command",
        Category = "Server",
        Target = {}
    }

    function package.Target:Init()

    end

    return package
    ```

    ```lua
    
    function package.Target:Init()

    end

    ```

    The `package.Target:Init()` is an `invoker` function, it gets invoked when the player requested for this command, you can write in your main function for this command there. The invoker function will receive three arguments when invoked, which is the requester `PlayerWrapper` object, the request type, and finally the actual arguments provided by the requester -- the attachments.

    While this command will not make use of any of the arguments above, we will be writing it down below for your future reference.

    Now, let's write down our main function for this command, which is printing `"Hello World"` to the console.

    ```lua
    
    function package.Target:Init(player, requestType, arguments)
        print("Hello World")
        return true
    end

    ```

    !!! tip "Always return a boolean back to the requester"
        Because this is an `invoker` function, the function requires to return something back to the client to avoid potential halting in the client side, while this will not affect the server, this can lead to a lot of problems to the client instead.

        If the command runs successfully (everything listed in the main function is completed), return a true boolean. Otherwise, return a false boolean along with the error message.

    That's all. :tada: