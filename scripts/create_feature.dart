// Scaffolds a new feature folder matching the exact structure of
// lib/features/example_feature.
//
// Usage (from the project root):
//   dart run scripts/create_feature.dart --name my_feature            # bloc (lists/pagination)
//   dart run scripts/create_feature.dart --name my_feature --cubit    # cubit (forms/simple screens)
//
// dart run scripts/create_feature.dart --name favorites
// أو إذا الميزة بسيطة (شاشة نموذج، مو قائمة بها scroll/pagination):
// dart run scripts/create_feature.dart --name profile --cubit
// الفرق بين الوضعين
// بدون --cubit (الافتراضي): بيولّد Bloc — مناسب لشاشات فيها قوائم، pagination، أحداث متعددة (Events)
// مع --cubit: بيولّد Cubit — أبسط، مناسب لشاشات نموذج (form) أو حالة بسيطة
// 
// 
//
//
//
//
//
//
//
//
//
//  
// After generating:
//   1. dart run build_runner build --delete-conflicting-outputs
//   2. Add the page route to lib/core/routing/routes.dart + app_router.dart
//   3. Add your endpoints to lib/core/network/endpoints.dart\

import 'dart:io';

void main(List<String> args) {
  String? name;
  bool useCubit = false;
  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--name' && i + 1 < args.length) name = args[i + 1];
    if (args[i] == '--cubit') useCubit = true;
  }
  if (name == null || !RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    stderr.writeln('Usage: dart run scripts/create_feature.dart --name my_feature [--cubit]');
    exit(64);
  }

  final String snake = name;
  final String pascal = snake.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join();
  final String root = 'lib/features/$snake';

  if (Directory(root).existsSync()) {
    stderr.writeln('Feature "$snake" already exists at $root.');
    exit(1);
  }

  final Map<String, String> files = {
    '$root/data/data_sources/${snake}_remote_data_source.dart': '''
abstract class ${pascal}RemoteDataSource {
  // TODO: declare data-source methods returning models, e.g.:
  // Future<${pascal}Model> get$pascal();
}
''',
    '$root/data/data_sources/${snake}_remote_data_source_impl.dart': '''
import 'package:injectable/injectable.dart';

import '../../../../core/data_source/remote/base_remote_data_source_impl.dart';
import '${snake}_remote_data_source.dart';

@LazySingleton(as: ${pascal}RemoteDataSource)
class ${pascal}RemoteDataSourceImpl extends BaseRemoteDataSourceImpl implements ${pascal}RemoteDataSource {
  ${pascal}RemoteDataSourceImpl(super._dio);

  // TODO: implement methods with performGetRequest / performPostRequest / ...
  // and parse: Model.fromJson(baseModel.data) or PaginationModel.fromJson(baseModel.toJson())
}
''',
    '$root/data/models/.gitkeep': '',
    '$root/data/repositories/${snake}_repository_impl.dart': '''
import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../domain/repositories/${snake}_repository.dart';
import '../data_sources/${snake}_remote_data_source.dart';

@LazySingleton(as: ${pascal}Repository)
class ${pascal}RepositoryImpl extends BaseRepositoryImpl implements ${pascal}Repository {
  // ignore: unused_field
  final ${pascal}RemoteDataSource _${_camel(snake)}RemoteDataSource;

  ${pascal}RepositoryImpl(
    this._${_camel(snake)}RemoteDataSource,
  ) : super('${pascal}Repository');

  // TODO: implement the repository contract with execute(..., converter: model.toDomain())
}
''',
    '$root/domain/entities/.gitkeep': '',
    '$root/domain/repositories/${snake}_repository.dart': '''
import '../../../../core/repositories/base_repository.dart';

abstract class ${pascal}Repository extends BaseRepository {
  // TODO: declare methods returning Future<RequestResult<Entity>>
}
''',
    '$root/domain/use_cases/.gitkeep': '',
    '$root/presentation/pages/${snake}_page.dart': '''
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_scaffold.dart';

class ${pascal}Page extends StatelessWidget {
  const ${pascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      body: Center(child: Text('$pascal')),
    );
  }
}
''',
    '$root/presentation/widgets/.gitkeep': '',
  };

  if (useCubit) {
    files['$root/presentation/cubit/${snake}_state.dart'] = '''
import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';

part '${snake}_state.g.dart';

abstract class ${pascal}State implements Built<${pascal}State, ${pascal}StateBuilder> {
  Status get status;
  Failure? get failure;

  ${pascal}State._();
  factory ${pascal}State([void Function(${pascal}StateBuilder) updates]) = _\$${pascal}State;

  factory ${pascal}State.initial() => ${pascal}State(
    (b) => b
      ..status = Status.initial
      ..failure = null,
  );
}
''';
    files['$root/presentation/cubit/${snake}_cubit.dart'] = '''
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/${snake}_repository.dart';
import '${snake}_state.dart';

@injectable
class ${pascal}Cubit extends Cubit<${pascal}State> {
  // ignore: unused_field
  final ${pascal}Repository _${_camel(snake)}Repository;

  ${pascal}Cubit(this._${_camel(snake)}Repository) : super(${pascal}State.initial());

  // TODO: add methods that emit state.rebuild((b) => b..status = ...)
}
''';
  } else {
    files['$root/presentation/bloc/${snake}_event.dart'] = '''
import 'package:built_value/built_value.dart';

part '${snake}_event.g.dart';

sealed class ${pascal}Event {}

abstract class Get$pascal extends ${pascal}Event implements Built<Get$pascal, Get${pascal}Builder> {
  bool get reInitialData;

  Get$pascal._();
  factory Get$pascal([void Function(Get${pascal}Builder) updates]) = _\$Get$pascal;
}
''';
    files['$root/presentation/bloc/${snake}_state.dart'] = '''
import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';

part '${snake}_state.g.dart';

abstract class ${pascal}State implements Built<${pascal}State, ${pascal}StateBuilder> {
  Status get status;
  Failure? get failure;

  ${pascal}State._();
  factory ${pascal}State([void Function(${pascal}StateBuilder) updates]) = _\$${pascal}State;

  factory ${pascal}State.initial() => ${pascal}State(
    (b) => b
      ..status = Status.initial
      ..failure = null,
  );
}
''';
    files['$root/presentation/bloc/${snake}_bloc.dart'] = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/${snake}_repository.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

@injectable
class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  // ignore: unused_field
  final ${pascal}Repository _${_camel(snake)}Repository;

  ${pascal}Bloc(this._${_camel(snake)}Repository) : super(${pascal}State.initial()) {
    on<Get$pascal>((event, emit) async {
      emit(
        state.rebuild(
          (b) => b
            ..status = Status.loading
            ..failure = null,
        ),
      );
      // TODO: call a use case / the repository and fold(success/failure).
      // See lib/features/example_feature/presentation/bloc/example_feature_bloc.dart
    });
  }
}
''';
  }

  files.forEach((path, content) {
    final File file = File(path);
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    stdout.writeln('Created: $path');
  });

  stdout.writeln('');
  stdout.writeln('Feature "$snake" scaffolded. Next steps:');
  stdout.writeln('  1. dart run build_runner build --delete-conflicting-outputs');
  stdout.writeln('  2. Register the route in lib/core/routing/routes.dart and app_router.dart');
  stdout.writeln('  3. Add endpoints in lib/core/network/endpoints.dart');
}

String _camel(String snake) {
  final List<String> parts = snake.split('_');
  return parts.first + parts.skip(1).map((word) => word[0].toUpperCase() + word.substring(1)).join();
}
