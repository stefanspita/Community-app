grey = "#404040,#4b4b4b,#575757,#646464,#717171".split(",")
blue = "#3e7ba1,#478eba,#51a2d4,#5fbdf9,#6dd8ff".split(",")
green = "#506930,#5c7837,#698a3f,#7ca14a,#8db854".split(",")
orange = "#ff6c00,#ff8e00,#ff8e00,#ffa500,#ffbc00".split(",")
red = "#A13E3E,#BA4747,#D45151,#F95F5F,#FF6D6D".split(",")
stacked="#ff8e00,#51a2d4,#ff6c00,#3e7ba1,#ffa500,#5fbdf9,#ff8e00,#51a2d4,#ff6c00,#3e7ba1,#ffa500,#5fbdf9".split(",")

#
allColors = {orange,blue,green,red, grey}
all = [].concat(blue,green,orange, red, grey)
mix = []
mix2 = []
for i in [2,3,4,1,0]
  for color in ["green","blue","orange","grey", "red"]
    mix.push allColors[color][i]
for i in [2..4]
  for key, colors of allColors when key isnt "grey"
    mix2.push colors[i]

allColors.mix = mix
allColors.mix2 = mix2
allColors.orangeBlue = [orange[0]].concat(blue)
allColors.spectral = ["#9e0142","#d53e4f","#f46d43","#fdae61","#fee08b","#ffffbf","#e6f598","#abdda4","#66c2a5","#3288bd","#5e4fa2"]
allColors.spectral2 = ["#a50026","#d73027","#f46d43","#fdae61","#fee08b","#ffffbf","#d9ef8b","#a6d96a","#66bd63","#1a9850","#006837"]
allColors.spectral3 = ["#fcfbfd","#efedf5","#dadaeb","#bcbddc","#9e9ac8","#807dba","#6a51a3","#54278f","#3f007d","#fff5eb","#fee6ce","#fdd0a2","#fdae6b","#fd8d3c","#f16913","#d94801","#a63603","#7f2704"]
allColors.mix3=stacked
module.exports = allColors
