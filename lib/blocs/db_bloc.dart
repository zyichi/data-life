import 'package:bloc/bloc.dart';
import 'package:data_life/db/life_db.dart';


abstract class DbEvent {}


class OpenDb extends DbEvent {}


abstract class DbState {}


class DbClosed extends DbState {}
class DbOpen extends DbState {}
class DbError extends DbState {}


class DbBloc extends Bloc<DbEvent, DbState> {
  @override
  DbState get initialState => DbClosed();

  @override
  Stream<DbState> mapEventToState(DbEvent event) async* {
    if (event is OpenDb) {
      try {
        // await LifeDb.delete();
        await LifeDb.open();
        yield DbOpen();
      } catch (_) {
        yield DbError();
      }
    }
  }
}
