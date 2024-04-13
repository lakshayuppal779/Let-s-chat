
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/notesMaking/ui/views/GroupCreationPage.dart';

import '../../cubit/Group.cubit.dart';
import '../../cubit/Note.cubit.dart';
import '../../models/Group.model.dart';
import 'BottomModal.dart';

class BottomGroupModal extends StatelessWidget {
  final Group group;

  final List<Widget> children;

  const BottomGroupModal({
    super.key,
    required this.group,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {

    return BottomModal(
      createdAt: group.createdAt!,
      onDelete: () {
        Navigator.of(context).pop();
        // cubit delete note
        context.read<GroupCubit>().delete(group);
        context.read<NoteCubit>().removeGroup(group);

      },
      onEdit: () {
        Navigator.of(context).pop();
        // Go to the edit note page
        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupCreationPage(group: group)));
      },
      children: children,
    );
  }
}

