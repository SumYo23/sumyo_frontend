import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:v2/repositories/token_repository.dart';
import '../models/ingredient_model.dart';

class IngredientRepository {
  Future<String> TOKEN = TokenRepository().getDeviceId();
  Future<List<Ingredient>> fetchIngredients() async {

    final url = 'http://223.130.139.200/api/refrigerator/list/';
    final headers = {
      'Authorization': await TOKEN,
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        List<dynamic> jsonBody = jsonDecode(body);
        List<Ingredient> ingredients = jsonBody.map((dynamic item) => Ingredient.fromJson(item)).toList();
        print('ingredient fetch success');
        return ingredients;
      } else {
        print('Server Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Fetching Error: $e');
      return [];
    }

  }

  Future<bool> addIngredient(Ingredient ingredient) async {

    final url = 'http://223.130.139.200/api/refrigerator/list/';

    final request = json.encode({
      'ingredient': ingredient.ingredient,
      'quantity': ingredient.quantity.toString(),
      // 'Host' : '223.130.139.200'
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        body: request,
        headers: {
          //'Content-Length' : json.decode(request).length.toString(),
          'Content-Type': 'application/json',
          'Authorization': await TOKEN,
        },
      );
      print(await TOKEN);

      if (response.statusCode != 200) {
        print('Error updating ingredient1: ${response.statusCode}');
        return false;
      }
      return true;
    } catch (error) {
      print('Error updating ingredient2: $error');
      return false;
    }

  }

  Future<void> updateIngredient(String ingredient,int quantity) async {

    final url = 'http://223.130.139.200/api/refrigerator/list/$ingredient/';
    final headers = {
      'Authorization': await TOKEN,
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      'quantity': quantity,
    });
    try {
      final response = await http.put(Uri.parse(url), headers: headers,body:body);

      if (response.statusCode == 200) {
        print('Update request sent successfully');
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteIngredient(String ingredient) async {
    final url = 'http://223.130.139.200/api/refrigerator/list/$ingredient/';
    final headers = {
      'Authorization': await TOKEN,
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        print('Ingredient successfully deleted');
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Deleting Error: $e');
    }
  }

  Future<List> detectIngredientsFromImage(XFile image) async {

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://223.130.139.200/api/ai/'),
    );

    request.headers.addAll({});

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
    ));

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);
    final extractedData = json.decode(utf8.decode(responseData.bodyBytes)) as Map<String, dynamic>;
    final foods = extractedData['foods'] as List<dynamic>;
    print(foods[0]);
    return foods;
  }

}
