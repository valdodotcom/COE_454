import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/post.dart';
import 'package:flutter_testing_tutorial/story_change_notifier.dart';
import 'package:flutter_testing_tutorial/story_page.dart';
import 'package:flutter_testing_tutorial/story_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockStoryService extends Mock implements StoryService {}

void main() {
  late MockStoryService mockStoryService;

  setUp(() {
    mockStoryService = MockStoryService();
  });

  final postsFromService = [
    Post(title: 'Test 1', content: 'Test 1 content'),
    Post(title: 'Test 2', content: 'Test 2 content'),
    Post(title: 'Test 3', content: 'Test 3 content'),
  ];
  void arrangeStoryServiceReturns3Posts() {
    when(() => mockStoryService.getPosts())
        .thenAnswer((_) async => postsFromService);
  }

  void arrangeStoryServiceReturns3PostsAfterDelay() {
    when(() => mockStoryService.getPosts()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return postsFromService;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'Story Time',
      home: ChangeNotifierProvider(
        create: (_) => StoryChangeNotifier(mockStoryService),
        child: StoryPage(),
      ),
    );
  }

  testWidgets("Title is displayed", (WidgetTester tester) async {
    arrangeStoryServiceReturns3Posts();
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Story Time'), findsOneWidget);
  });

  testWidgets("Loading indicator is displayed while waiting for posts",
      (WidgetTester tester) async {
    arrangeStoryServiceReturns3PostsAfterDelay();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets("Articles are displayed", (WidgetTester tester) async {
    arrangeStoryServiceReturns3Posts();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    for (final post in postsFromService) {
      expect(find.text(post.title), findsOneWidget);
      expect(find.text(post.content), findsOneWidget);
    }
  });
}
