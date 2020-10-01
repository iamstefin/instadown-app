import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

Future<String> getFullURLOne(String url) async {
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var re = RegExp(r'(?<=meta property="og:image" content=")(.*)(?=" />)');
    var match = re.firstMatch(response.body);
    if (match != null) return match.group(0).toString();
  } else {
    print("Some Error Occured!");
    return "";
  }
  return "";
}

Stream<String> getFullURLMultiple(String url) async* {
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var re = RegExp(r'(?<=window._sharedData = )(.*)(?=;</script>)');
    var match = re.firstMatch(response.body);
    var decoded = json.decode(match.group(0).toString());
    for (var item in decoded['entry_data']['PostPage'][0]['graphql']
        ['shortcode_media']['edge_sidecar_to_children']['edges']) {
      yield item['node']['display_url'];
    }
  }
}

/*
USAGE 
var url = "https://www.instagram.com/p/CFYLF1Ms4ur";
var full_url = await GetFullURL(url);
return  full_url;
*/
