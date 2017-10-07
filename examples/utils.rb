def pngFilename(scriptFilename)
  base = File.basename(scriptFilename, ".rb")
  dir = File.dirname(scriptFilename)
  File.join(dir, "#{base}.png")
end
