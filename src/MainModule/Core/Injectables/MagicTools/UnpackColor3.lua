return function(packedColor3: {R: Number, G: Number, B: Number}): Color3
    return Color3.new(unpack(packedColor3))
end