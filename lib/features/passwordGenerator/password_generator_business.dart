Map<String, String> checkInputs(String length, List<bool> uses){
  try{
    if (int.parse(length.trim()) < 1){
      return {
      'title': 'Ошибка!', 
      "content": "Длина должна быть любым положительным числом от 1",
      "isRender": 'true'
      };
    }
  }
  catch (exception){
    return {
      'title': 'Ошибка!', 
      "content": "Длина должна быть любым положительным числом от 1",
      "isRender": "true"
    };
  }

  if (!uses.contains(true)){
    return {
      'title': 'Ошибка!', 
      'content': 'Должен быть включен хоть 1 параметр допустимых символов',
      "isRender": 'true'
    };
  }
  return {'isRender': 'false'};
}