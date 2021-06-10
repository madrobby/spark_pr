require_relative '../spark_pr.rb'
require_relative './utils.rb'

data = [
  { 47 => SparkCanvas::RED },
  { 43 => SparkCanvas::RED },
  { 24 => SparkCanvas::GREEN },
  { 47 => SparkCanvas::GREEN },
  { 16 => SparkCanvas::RED },
  { 28 => SparkCanvas::RED },
  { 38 => SparkCanvas::RED },
  { 57 => SparkCanvas::GREEN },
  { 50 => SparkCanvas::GREEN },
  { 76 => SparkCanvas::GRAY },
  { 42 => SparkCanvas::YELLOW },
  { 20 => SparkCanvas::YELLOW },
  { 98 => SparkCanvas::GREEN },
  { 34 => SparkCanvas::RED },
  { 53 => SparkCanvas::GREEN },
  { 1 => SparkCanvas::RED },
  { 55 => SparkCanvas::GREEN },
  { 74 => SparkCanvas::GREEN },
  { 63 => SparkCanvas::GREEN },
  { 38 => SparkCanvas::GREEN },
  { 31 => SparkCanvas::RED },
  { 98 => SparkCanvas::GREEN },
  { 89 => SparkCanvas::GREEN },
]

File.open(pngFilename(__FILE__), 'wb' ) do |png|
  png << Spark.plot(
    data,
    :type => 'bar',
    :height => 40,
  )
end
