import 'package:data_life/paging/page_repository.dart';

import 'package:data_life/models/action.dart';
import 'package:data_life/repositories/action_provider.dart';


class ActionRepository extends PageRepository<MyAction> {
  final ActionProvider _actionProvider;

  ActionRepository(this._actionProvider);

  @override
  Future<int> count() async {
    return _actionProvider.count();
  }

  @override
  Future<List<MyAction>> get({int startIndex, int count}) async {
    return _actionProvider.get(startIndex: startIndex, count: count);
  }

  Future<MyAction> getViaName(String name) async {
    return _actionProvider.getViaName(name);
  }

  Future<List<MyAction>> search(String pattern) async {
    return _actionProvider.search(pattern);
  }

  Future<int> save(MyAction action) async {
    return _actionProvider.save(action);
  }
}
