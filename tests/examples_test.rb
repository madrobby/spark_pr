require 'fileutils'

# This project is so small, let's just roll our own dead-simple testing
# "framework". No need to pull in anything fancier.

def run_test_suite!
  assert_example_image("bar")
  assert_example_image("bar-colors")
  assert_example_image("line")
  assert_example_image("discrete")
end

def assert_example_image(type)
  script       = "examples/#{type}.rb"
  exampleImage = "examples/#{type}.png"
  testImage    = "tests/#{type}.png"

  FileUtils.mv(exampleImage, testImage)

  load script

  pass = FileUtils.compare_file(exampleImage, testImage)
  FileUtils.mv(testImage, exampleImage)

  if pass
    puts "PASS: #{exampleImage} is correct."
  else
    msg = "FAIL: #{exampleImage} did not generate correctly."
    puts msg
    throw msg
  end
end

run_test_suite!
