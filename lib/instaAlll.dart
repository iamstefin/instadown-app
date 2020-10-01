/*
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() async {
  var url = "https://www.instagram.com/p/B27UTWZDlZY/";
  await for (var u in getFullURL(url)) {
    print(u);
  }
}

Stream<String> getFullURL(String url) async* {
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
*/
