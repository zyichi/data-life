import 'package:bloc/bloc.dart';
import 'package:data_life/db/life_db.dart';
import 'package:data_life/models/moment_contact.dart';
import 'package:uuid/uuid.dart';

import 'package:data_life/db/goal_table.dart';
import 'package:data_life/db/goal_action_table.dart';
import 'package:data_life/db/todo_table.dart';
import 'package:data_life/db/moment_table.dart';
import 'package:data_life/db/moment_contact_table.dart';

import 'package:data_life/repositories/goal_provider.dart';
import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/moment_provider.dart';
import 'package:data_life/repositories/moment_repository.dart';


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
        // await _upgradeDb();
        yield DbOpen();
      } catch (_) {
        yield DbError();
      }
    }
  }

/*
  Future<void> _upgradeDb() async {
    try {
      var goalRepository = GoalRepository(GoalProvider());
      var goals = await goalRepository.getAll();
      await LifeDb.db.execute('delete from ${GoalTable.name}');
      await LifeDb.db.execute('delete from ${GoalActionTable.name}');
      for (var goal in goals) {
        goal.uuid = Uuid().v4();
        for (var ga in goal.goalActions) {
          ga.uuid = Uuid().v4();
          ga.goalUuid = goal.uuid;
          await goalRepository.addGoalAction(ga);
        }
        await goalRepository.add(goal);
      }
    } catch (e) {
      print('Upgrade uuid for goal/goal_action table failed: ${e.toString()}');
    }

    try {
      var momentRepository = MomentRepository(MomentProvider());
      var moments = await momentRepository.getAll();
      await LifeDb.db.execute('delete from ${MomentTable.name}');
      await LifeDb.db.execute('delete from ${MomentContactTable.name}');
      for (var moment in moments) {
        var mcList = await momentRepository.getMomentContact(moment.uuid);
        moment.uuid = Uuid().v4();
        for (var mc in mcList) {
          mc.momentUuid = moment.uuid;
          await momentRepository.saveMomentContact(mc);
        }
        await momentRepository.add(moment);
      }
    } catch (e) {
      print('Upgrade uuid for moment/moment_contact table failed: ${e.toString()}');
    }
  }
  */
}
