# API Manual

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

### API.addChecker(name: string, checkerFunction: function) -> void
Loads in a checker given in the function call, will be called when a player joins.

### API.checkUserAdmin(player) -> boolean
Returns the player's administrator status