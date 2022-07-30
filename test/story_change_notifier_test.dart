import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/post.dart';
import 'package:flutter_testing_tutorial/story_change_notifier.dart';
import 'package:flutter_testing_tutorial/story_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStoryService extends Mock implements StoryService {}

void main() {
  late StoryChangeNotifier sut;
  late MockStoryService mockStoryService;

  setUp(() {
    mockStoryService = MockStoryService();
    sut = StoryChangeNotifier(mockStoryService);
  });

  test("The initial values are correct", () {
    expect(sut.isLoading, false);
    expect(sut.posts, []);
  });

  group('getPosts', () {
    final postsFromService = [
      Post(title: 'Test 1', content: 'Test 1 content'),
      Post(title: 'Test 2', content: 'Test 2 content'),
      Post(title: 'Test 3', content: 'Test 3 content'),
    ];
    void arrangeStoryServiceReturns3Posts() {
      when(() => mockStoryService.getPosts())
          .thenAnswer((_) async => postsFromService);
    }

    test("gets articles using the StoryService", () async {
      arrangeStoryServiceReturns3Posts();
      await sut.getPosts();
      verify(() => mockStoryService.getPosts()).called(1);
    });

    test(
        """indicates loading of data, sets articles to the ones from the service, indicates that the data is not being loaded anymore""",
        () async {
      arrangeStoryServiceReturns3Posts();
      final future = sut.getPosts();
      expect(sut.isLoading, true);
      await future;
      expect(sut.posts, postsFromService);
      expect(sut.isLoading, false);
    });
  });
}
