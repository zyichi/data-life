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
        await _upgradeDb();
        yield DbOpen();
      } catch (_) {
        yield DbError();
      }
    }
  }

  Future<void> _upgradeDb() async {
    /*
    LifeDb.db.transaction((txn) async {
      // Upgrade task table
      await txn.execute('drop table ${TodoTable.name}');
      for (var sql in TodoTable.initSqlList) {
        await txn.execute(sql);
      }

      // Upgrade goal table
      await txn.execute('alter table ${GoalTable.name} add ${GoalTable.columnDoneTime} integer default null');
      await txn.execute('alter table ${GoalTable.name} rename to goal_tmp');
      for (var sql in GoalTable.initSqlList) {
        await txn.execute(sql);
      }
      await txn.execute('insert into ${GoalTable.name} select * from goal_tmp');

      // Upgrade goal_action table
      await txn.execute('alter table ${GoalActionTable.name} rename to goal_action_tmp');
      for (var sql in GoalActionTable.initSqlList) {
        await txn.execute(sql);
      }
      await txn.execute('insert into ${GoalActionTable.name} select * from goal_action_tmp');

      // Upgrade moment table
      await txn.execute('alter table ${MomentTable.name} rename to moment_tmp');
      for (var sql in MomentTable.initSqlList) {
        await txn.execute(sql);
      }
      await txn.execute('insert into ${MomentTable.name} select * from moment_tmp');

      // Upgrade moment_contact table
      await txn.execute('alter table ${MomentContactTable.name} rename to moment_contact_tmp');
      for (var sql in MomentContactTable.initSqlList) {
        await txn.execute(sql);
      }
      await txn.execute('insert into ${MomentContactTable.name} select * from moment_contact_tmp');
    });

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

    await db.execute('create table tt (_id integer primary key autoincrement, name text)');
    await db.execute("insert into tt (name) values ('Zhang Yi Chi')");
    await db.execute("insert into tt (name) values ('Ya Bao')");
    await db.execute('alter table tt rename to tt_tmp');
    await db.execute('create table tt (uuid text primary key, name text)');
    await db.execute('insert into tt select * from tt_tmp');
    await db.execute('alter table tt add doneTime after _id integer default null');
     */
  }
}
