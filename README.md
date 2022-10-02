# flutter_bloc_challenge

# Bloc 이란?

Bloc은 **B**usiness **Lo**gic **C**omponents의 약자이다. 

# Architecture

bloc의 architecture은 

- **Presentation**
- **Business Logic**
- **Data**
    - Repository
    - Data Provider

으로 구성되어 있다.

## Data Layer

<aside>

**The data layer's responsibility is to retrieve/manipulate data from one or more sources.**

</aside>

Data Layer는 크게 두 가지로 나뉠 수 있다. 

- Repository
- Data Provider

### 1. **Data Provider**

<aside>

**The data provider's responsibility is to provide raw data. The data provider should be generic and versatile.**

</aside>

Data Provider는 data를 전달해주는 역할만을 수행한다.

<aside>

**We might have a `createData`, `readData`, `updateData`, and `deleteData` method as part of our data layer.**

</aside>

여기서 사용되는 메소드명을 봐서는 뒤에 data를 붙여주는 것 같다. 별론데…

```dart
class DataProvider {
    Future<RawData> readData() async {
        // Read from DB or make network request etc...
    }
}
```

### 2. Repository

<aside>

**The repository layer is a wrapper around one or more data providers with which the Bloc Layer communicates.**

</aside>

Repository는 하나 또는 하나 이상의 Data Provider로 구성된 wrapper class 이다. 

```dart
class Repository {
    final DataProviderA dataProviderA;
    final DataProviderB dataProviderB;

    Future<Data> getAllDataThatMeetsRequirements() async {
        final RawDataA dataSetA = await dataProviderA.readData();
        final RawDataB dataSetB = await dataProviderB.readData();

        final Data filteredData = _filterData(dataSetA, dataSetB);
        return filteredData;
    }
}
```

## Business Logic Layer

<aside>

**The business logic layer's responsibility is to respond to input from the presentation layer with new states. This layer can depend on one or more repositories to retrieve data needed to build up the application state.**

</aside>

business logic layer는 presentation 에서 오는 입력 사항들을 기반으로 상태를 변경시키는 역할을 한다. 

architecture 측면에서 보면 Data와 Presentation의 중간다리 역할을 해준다고 생각하면 편할 것 같다. 

```dart
class BusinessLogicComponent extends Bloc<MyEvent, MyState> {
    BusinessLogicComponent(this.repository) {
        on<AppStarted>((event, emit) {
            try {
                final data = await repository.getAllDataThatMeetsRequirements();
                emit(Success(data));
            } catch (error) {
                emit(Failure(error));
            }
        });
    }

    final Repository repository;
}
```

코드에서 보면 하나의 Bloc은 Event와 State로 구성되어 있다. 

input → event

ouput → state

input → output 사이의 로직이 Bloc의 핵심이라고 할 수 있겠다. 

### Bloc-to-Bloc Comunication

**Because blocs expose streams, it may be tempting to make a bloc which listens to another bloc. You should **not** do this. There are better alternatives than resorting to the code below:**

Bloc pattern 에서는 Bloc 간의 통신을 지원한다. 개발을 하다보면 로직 별로 분리하고 싶은 욕망이 커질텐데 분리된 Bloc 사이에 통신은 필수적일 것으로 보인다. 

```dart
class BadBloc extends Bloc {
  final OtherBloc otherBloc;
  late final StreamSubscription otherBlocSubscription;

  BadBloc(this.otherBloc) {
    // No matter how much you are tempted to do this, you should not do this!
    // Keep reading for better alternatives!
    otherBlocSubscription = otherBloc.stream.listen((state) {
      add(MyEvent())
    });
  }

  @override
  Future<void> close() {
    otherBlocSubscription.cancel();
    return super.close();
  }
}
```

### Connecting Blocs through Presentation

<aside>

**You can use a `BlocListener`to listen to one bloc and add an event to another bloc whenever the first bloc changes.**

</aside>

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeatherCubit, WeatherState>(
      listener: (context, state) {
        // When the first bloc's state changes, this will be called.
        //
        // Now we can add an event to the second bloc without it having
        // to know about the first bloc.
        BlocProvider.of<SecondBloc>(context).add(SecondBlocEvent());
      },
      child: TextButton(
        child: const Text('Hello'),
        onPressed: () {
          BlocProvider.of<FirstBloc>(context).add(FirstBlocEvent());
        },
      ),
    );
  }
}
```

### Connecting Blocs through Domain

<aside>

**Two blocs can listen to a stream from a repository and update their states independent of each other whenever the repository data changes. Using reactive repositories to keep state synchronized is common in large-scale enterprise applications.**

</aside>

```dart
class AppIdeasRepository {
  int _currentAppIdea = 0;
  final List<String> _ideas = [
    "Future prediction app that rewards you if you predict the next day's news",
    'Dating app for fish that lets your aquarium occupants find true love',
    'Social media app that pays you when your data is sold',
    'JavaScript framework gambling app that lets you bet on the next big thing',
    'Solitaire app that freezes before you can win',
  ];

  Stream<String> productIdeas() async* {
    while (true) {
      yield _ideas[_currentAppIdea++ % _ideas.length];
      await Future<void>.delayed(const Duration(minutes: 1));
    }
  }
}
```

```dart
class AppIdeaRankingBloc
    extends Bloc<AppIdeaRankingEvent, AppIdeaRankingState> {
  AppIdeaRankingBloc({required AppIdeasRepository appIdeasRepo})
      : _appIdeasRepo = appIdeasRepo,
        super(AppIdeaInitialRankingState()) {
    on<AppIdeaStartRankingEvent>((event, emit) async {
      // When we are told to start ranking app ideas, we will listen to the
      // stream of app ideas and emit a state for each one.
      await emit.forEach(
        _appIdeasRepo.productIdeas(),
        onData: (String idea) => AppIdeaRankingIdeaState(idea: idea),
      );
    });
  }

  final AppIdeasRepository _appIdeasRepo;
}
```

해당 파트는 정확히 무엇을 의미하는건지 잘 모르겠다.. 흠 

## Presentation Layer

<aside>

**The presentation layer's responsibility is to figure out how to render itself based on one or more bloc states. In addition, it should handle user input and application lifecycle events.**

</aside>

```dart
class PresentationComponent {
    final Bloc bloc;

    PresentationComponent() {
        bloc.add(AppStarted());
    }

    build() {
        // render UI based on bloc state
    }
}
```

### Reference

- [Bloc Document Official](https://bloclibrary.dev/#/architecture)
- [Bloc Naming Convention](https://bloclibrary.dev/#/blocnamingconventions)
