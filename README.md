## Spark_PR

A Ruby class to generate sparkline graphs with PNG or ASCII output.

Can be implemented into your app keeping a clean RESTful interface, 

## Implementation

Step 1: Put spark_pr.rb file into lib directory.

Step 2:
```ruby
require "spark_pr"
```

Step 3:
```ruby
include Spark
```
in your controller

Step 4: Add PNG format to controller 

```ruby
def graph
    @statsgraph = ...

    respond_to do |format|
      format.xml  { render :xml => @arraybig.to_xml }
      format.json { render :json => @arraybig.to_json }
      format.png { send_data(Spark.plot( @arraybig, :has_min => true, :has_max => true, 'has_last' => 'true', 'height' => '15', :step => 8 ), :type => 'image/png',
                    :filename => "#{params[:segment_id]}.png",
                    :disposition => 'inline') }
    end
end
```

  
Step 5: Put image_tag that requests the sparkline PNG image file into the view where you want it to appear:
```ruby
<%= image_tag(graph_segment_stats_path(stat.name, :format => 'png')) %>
```
  
That is all! The result is an awesome sparkline graph.
Its a clear, fast visual representation of data, which has the three major points
- [min, max, last] points  highlighted.



## Other usages

Example ASCII output:

```ruby
puts Spark.smooth( [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 1, 98, 34, 53, 97, 55, 74, 63, 38, 31, 98, 89], :has_min => true, :has_max => true, :height => 14, :step => 4 ).to_ascii
```

The SparkCanvas class can also be used for other drawing operations,
it provides drawing canvas with alpha blending and some primitive graphics
operations and PNG output in just about 100 lines of Ruby code.

Pure Ruby sparklines are released under the terms of the MIT-LICENSE.
See the included MIT-LICENSE file for details.
