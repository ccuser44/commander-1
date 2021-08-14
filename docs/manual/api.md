# API
The API is a collection of reusable functions that helps to reduce the size of a package, or for developers to communicate with Commander externally. As the API is exposed to the server context, please be aware of backdoors, as they may have codes to intervene Commander.

## Use-cases
The API offers opportunities for developers to create lightweight, safe and stable packages for Commander without putting too much focus on compatability. Here are the reasons why you should consider using the API instead of reinventing the wheels:

- Maintained by the official developers

The API is always up-to-date with the entire codebase and has been seriously tested before release, it is by far the most optimal way to create scalable packages.

- Code safety

All code found in the API is coded with caution, the chances of it breaking out of random is rare and physically impossible to happen.

- Saves line

With the use of the API, you can easily make your package extremely lightweight, as majority of the code has been replaced by API methods instead.

## Methods
### Players
#### API.checkUserAdmin
!!! abstract "`boolean` API.checkuserAdmin(`player` Player)" 
    Returns the administrator status of the user,

#### API.getAdminStatusWithUserId
!!! abstract "`number, string` API.getAdminStatusWithUserId(`integer` UserId)" 
    Returns the administration group index and name of the player is in. This method is for when the player is not ingame.

#### API.getAdminLevel
!!! abstract "`number, string` API.getAdminLevel(`player` Player)" 
    Returns the administration group index and name of the player is in.

#### API.initializePlayer
!!! abstract "`nil` API.initializePlayer(`player` Player)" 
    Initializes the player, this is not needed as Commander already calls this to every player by default.

#### API.wrapPlayer
!!! abstract "`table` API.wrapPlayer(`player` Player)" 
    Returns a wrapper of the player. By default, the wrapper contains the following elements:

    ```lua
    {
        ["Name"] = Player.Name,
        ["DisplayName"] = Player.DisplayName,
        ["UserId"] = Player.UserId,
        ["Character"] = Player.Character,
        ["IsAdmin"] = API.checkUserAdmin(Player),
        ["_instance"] = Player
    }
    ```

#### API.getProfile
!!! abstract "`profile` API.getProfile(`string|integer` user)"
    **:hourglass-flowing-sand: Asynchronous operation**
    Returns the profile of the user

    :warning: Release the profile once you are done working with it, for more details, refer to the documentation for [ProfileService](https://madstudioroblox.github.io/ProfileService/)

### Misc
#### API.addChecker
!!! abstract "`nil` API.addChecker(`string` Name, `function` Checker)" 
    Loads in a checker given in the function call, will be called when a player joins.

#### API.extendPlayerWrapper
!!! abstract "`nil` API.extendPlayerWrapper(`function` Extender)" 
    Loads in an extender given in the function call, will be called when .wrapPlayer is requested.

#### API.Initialize
!!! abstract "`nil` API.Initialize(`Folder` remotesFolder)"
    Avoid touching this part, this is meant to be used internally.

#### API.addRemoteTask
!!! abstract "`table` API.addRemoteTask(`string` remoteType, `function|string` qualifier, `function` handler)" 
    Adds a new task to the corresponding, useful when you want to listen RemoteFunction/Event requests.

    Accepted remoteTypes: `"Function"`, `"Event"`

    Returns a table, for you to remove the task once you no longer want to listen:

    ```lua
    local task = API.addRemoteTask("Function", "onRequest", function(player, requestType, ...)
        return true
    end)

    task.leave() -- leaves
    ```

    When a handler is being fired, you are expected to receive the player wrapper, the request type, and the arguments.