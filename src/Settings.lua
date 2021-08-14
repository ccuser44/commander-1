return {
    Permissions = {
        {
            Type = "Group",
            Group = "Moderator",
            Authorize = "3430014",
            Range = {1, 255},
            AcceptEqual = true,
        },
        {
            Type = "Username",
            Group = "Administrator",
            Authorize = {"7kayoh", "builderman"},
        },
        {
            Type = "UserId",
            Group = "Administrator",
            Authorize = {"1024", "2048"},
        }
    },

    Groups = {
        {
            Name = "Moderator",
            Commands = {
                "Kill",
                "Kick",
                "Ban",
                "Message",
                "Hint",
                "PrivateMessage"
            }
        },
        {
            Name = "Administrator",
            Commands = {
                "*"
            }
        },
    },

    Profiles = {
        PlayerProfileStoreIndex = "commander.plrProfileStore",
        LogProfileStoreIndex = "commander.logProfileStore",
    },

    Interface = {
        DefaultLanguage = "en",
        DefaultTheme = "default",
        DefaultThemeColor = Color3.fromRGB(64, 157, 130),
        DefaultKeybind = Enum.KeyCode.Semicolon
    },

    Others = {
        HideCredits = false
    }
}