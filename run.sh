tshark -x -Y 'http.content_type=="application/json"' > tshark_dump
ruby parse_tshark_dump.rb tshark_dump json_dump
ruby parse.rb json_dump
