require_relative '../spark_pr.rb'
require_relative './utils.rb'

data = [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89]

File.open(pngFilename(__FILE__), 'wb' ) do |png|
  png << Spark.plot(
    data,
    :type => 'discrete',
    :has_min => true,
    :has_max => true,
    :has_last => true,
    :height => 40,
    :step => 10,
    :normalize => 'logarithmic'
  )
end
