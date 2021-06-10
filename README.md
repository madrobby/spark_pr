spark_pr is a Ruby class to generate sparkline graphs with PNG or ASCII output.

It only depends on zlib and generates PNGs with pure Ruby code.
The line-graph outputs antialised lines.

The SparkCanvas class can also be used for other drawing operations,
it provides drawing canvas with alpha blending and some primitive graphics
operations and PNG output in just about 100 lines of Ruby code.


# Examples

## PNG output

```
require 'spark_pr.rb'
File.open( 'test.png', 'wb' ) do |png|
  png << Spark.plot( [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89], :has_min => true, :has_max => true, 'has_last' => 'true', 'height' => '40', :step => 10, :normalize => 'logarithmic' )
end
```


## ASCII output

```
require 'spark_pr.rb'
puts Spark.smooth( [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 1, 98, 34, 53, 97, 55, 74, 63, 38, 31, 98, 89], :has_min => true, :has_max => true, :height => 14, :step => 4 ).to_ascii
```

## Example scripts

Run the scripts in the `examples/` directory to generate images.


# License

Pure Ruby sparklines are released under the terms of the MIT-LICENSE.
See the included MIT-LICENSE file for details.
