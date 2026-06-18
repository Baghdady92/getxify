# GetXify

![GetXify](https://raw.githubusercontent.com/Aniketkhote/getxify/master/assets/getxify.png)

[![pub package](https://img.shields.io/pub/v/getxify?label=getxify&color=blue)](https://pub.dev/packages/getxify)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)
<a href="https://github.com/Solido/awesome-flutter">
<img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

**GetXify** is an improved and enhanced version of GetX - an extra-light and powerful solution for Flutter. It combines high-performance state management, intelligent dependency injection, and route management quickly and practically.

- [About GetXify](#about-getxify)
- [Installing](#installing)
- [Counter App with GetXify](#counter-app-with-getxify)
- [The Three Pillars](#the-three-pillars)
  - [State Management](#state-management)
    - [Reactive State Manager](#reactive-state-manager)
  - [Route Management](#route-management)
  - [Dependency Management](#dependency-management)
- [Utils](#utils)
  - [Internationalization](#internationalization)
  - [Change Theme](#change-theme)
  - [Other Advanced APIs](#other-advanced-apis)
- [Contributing](#contributing)
- [License](#license)

# About GetXify

GetXify is an improved and enhanced version of GetX, maintaining all the powerful features while adding improvements and fixes. It follows the same three basic principles: **PRODUCTIVITY, PERFORMANCE AND ORGANIZATION.**

- **PERFORMANCE:** GetXify is focused on performance and minimum consumption of resources. It does not use Streams or ChangeNotifier.

- **PRODUCTIVITY:** GetXify uses an easy and pleasant syntax. No matter what you want to do, there is always an easier way with GetXify. It will save hours of development and will provide the maximum performance your application can deliver.

- **ORGANIZATION:** GetXify allows the total decoupling of the View, presentation logic, business logic, dependency injection, and navigation. You do not need context to navigate between routes, so you are not dependent on the widget tree for this.

GetXify is not bloated. It has a multitude of features that allow you to start programming without worrying about anything, but each of these features are in separate containers and are only started after use.

# Installing

Add GetXify to your pubspec.yaml file:

```yaml
dependencies:
  getxify:
```

Import getxify in files that it will be used:

```dart
import 'package:getxify/getxify.dart';
```

# Counter App with GetXify

The "counter" project created by default on new project on Flutter has over 100 lines (with comments). To show the power of GetXify, I will demonstrate how to make a "counter" changing the state with each click, switching between pages and sharing the state between screens, all in an organized way, separating the business logic from the view, in ONLY 26 LINES CODE INCLUDING COMMENTS.

- Step 1:
  Add "GetX" before your MaterialApp, turning it into GetMaterialApp

```dart
void main() => runApp(GetMaterialApp(home: Home()));
```

- Note: this does not modify the MaterialApp of the Flutter, GetMaterialApp is not a modified MaterialApp, it is just a pre-configured Widget, which has the default MaterialApp as a child. You can configure this manually, but it is definitely not necessary. GetMaterialApp will create routes, inject them, inject translations, inject everything you need for route navigation. If you use GetXify only for state management or dependency management, it is not necessary to use GetMaterialApp. GetMaterialApp is necessary for routes, snackbars, internationalization, bottomSheets, dialogs, and high-level apis related to routes and absence of context.
- Note²: This step is only necessary if you gonna use route management (`Get.to()`, `Get.back()` and so on). If you not gonna use it then it is not necessary to do step 1

- Step 2:
  Create your business logic class and place all variables, methods and controllers inside it.
  You can make any variable observable using a simple ".obs".

```dart
class Controller extends GetxController{
  var count = 0.obs;
  increment() => count++;
}
```

- Step 3:
  Create your View, use StatelessWidget and save some RAM, with GetXify you may no longer need to use StatefulWidget.

```dart
class Home extends StatelessWidget {

  @override
  Widget build(context) {

    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final Controller c = Get.put(Controller());

    return Scaffold(
      // Use Obx(()=> to update Text() whenever count is changed.
      appBar: AppBar(title: Obx(() => Text("Clicks: ${c.count}"))),

      // Replace the 8 lines Navigator.push by a simple Get.to(). You don't need context
      body: Center(child: ElevatedButton(
              child: Text("Go to Other"), onPressed: () => Get.to(Other()))),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: c.increment));
  }
}

class Other extends StatelessWidget {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.
  final Controller c = Get.find();

  @override
  Widget build(context){
     // Access the updated count variable
     return Scaffold(body: Center(child: Text("${c.count}")));
  }
}
```

Result:

This is a simple project but it already makes clear how powerful GetXify is. As your project grows, this difference will become more significant.

GetXify was designed to work with teams, but it makes the job of an individual developer simple.

Improve your deadlines, deliver everything on time without losing performance. GetXify is not for everyone, but if you identified with that phrase, GetXify is for you!

# The Three pillars

## State management

GetXify has two different state managers: the simple state manager (we'll call it GetBuilder) and the reactive state manager (GetX/Obx)

### Reactive State Manager

Reactive programming can alienate many people because it is said to be complicated. GetXify turns reactive programming into something quite simple:

- You won't need to create StreamControllers.
- You won't need to create a StreamBuilder for each variable
- You will not need to create a class for each state.
- You will not need to create a get for an initial value.
- You will not need to use code generators

Reactive programming with GetXify is as easy as using setState.

Let's imagine that you have a name variable and want that every time you change it, all widgets that use it are automatically changed.

This is your count variable:

```dart
var name = 'Aniket Khote';
```

To make it observable, you just need to add ".obs" to the end of it:

```dart
var name = 'Aniket Khote'.obs;
```

And in the UI, when you want to show that value and update the screen whenever the values changes, simply do this:

```dart
Obx(() => Text("${controller.name}"));
```

That's all. It's _that_ simple.

### More details about state management

**See a more in-depth explanation of state management [here](./documentation/en_US/state_management.md). There you will see more examples and also the difference between the simple state manager and the reactive state manager**

You will get a good idea of GetXify power.

## Route management

If you are going to use routes/snackbars/dialogs/bottomsheets without context, GetXify is excellent for you too, just see it:

Add "GetX" before your MaterialApp, turning it into GetMaterialApp

```dart
GetMaterialApp( // Before: MaterialApp(
  home: MyHome(),
)
```

Navigate to a new screen:

```dart

Get.to(NextScreen());
```

Navigate to new screen with name. See more details on named routes [here](./documentation/en_US/route_management.md#navigation-with-named-routes)

```dart

Get.toNamed('/details');
```

To close snackbars, dialogs, bottomsheets, or anything you would normally close with Navigator.pop(context);

```dart
Get.back();
```

To go to the next screen and no option to go back to the previous screen (for use in SplashScreens, login screens, etc.)

```dart
Get.off(NextScreen());
```

To go to the next screen and cancel all previous routes (useful in shopping carts, polls, and tests)

```dart
Get.offAll(NextScreen());
```

Noticed that you didn't have to use context to do any of these things? That's one of the biggest advantages of using GetXify route management. With this, you can execute all these methods from within your controller class, without worries.

### More details about route management

**GetXify works with named routes and also offers lower-level control over your routes! There is in-depth documentation [here](./documentation/en_US/route_management.md)**

## Dependency management

GetXify has a simple and powerful dependency manager that allows you to retrieve the same class as your Bloc or Controller with just 1 lines of code, no Provider context, no inheritedWidget:

```dart
Controller controller = Get.put(Controller()); // Rather Controller controller = Controller();
```

- Note: If you are using GetXify's State Manager, pay more attention to the bindings API, which will make it easier to connect your view to your controller.

Instead of instantiating your class within the class you are using, you are instantiating it within the GetXify instance, which will make it available throughout your App.
So you can use your controller (or class Bloc) normally

**Tip:** GetXify dependency management is decoupled from other parts of the package, so if for example, your app is already using a state manager (any one, it doesn't matter), you don't need to rewrite it all, you can use this dependency injection with no problems at all

```dart
controller.fetchApi();
```

Imagine that you have navigated through numerous routes, and you need data that was left behind in your controller, you would need a state manager combined with the Provider or Get_it, correct? Not with GetXify. You just need to ask GetXify to "find" for your controller, you don't need any additional dependencies:

```dart
Controller controller = Get.find();
//Yes, it looks like Magic, GetXify will find your controller, and will deliver it to you. You can have 1 million controllers instantiated, GetXify will always give you the right controller.
```

And then you will be able to recover your controller data that was obtained back there:

```dart
Text(controller.textFromApi);
```

### More details about dependency management

**See a more in-depth explanation of dependency management [here](./documentation/en_US/dependency_management.md)**

# Utils

## Internationalization

### Translations

Translations are kept as a simple key-value dictionary map.
To add custom translations, create a class and extend `Translations`.

```dart
import 'package:getxify/getxify.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'hello': 'Hello World',
        },
        'de_DE': {
          'hello': 'Hallo Welt',
        }
      };
}
```

#### Using translations

Just append `.tr` to the specified key and it will be translated, using the current value of `Get.locale` and `Get.fallbackLocale`.

```dart
Text('title'.tr);
```

#### Using translation with singular and plural

```dart
var products = [];
Text('singularKey'.trPlural('pluralKey', products.length, Args));
```

#### Using translation with parameters

```dart
import 'package:getxify/getxify.dart';


Map<String, Map<String, String>> get keys => {
    'en_US': {
        'logged_in': 'logged in as @name with email @email',
    },
    'es_ES': {
       'logged_in': 'iniciado sesión como @name con e-mail @email',
    }
};

Text('logged_in'.trParams({
  'name': 'Jhon',
  'email': 'jhon@example.com'
  }));
```

### Locales

Pass parameters to `GetMaterialApp` to define the locale and translations.

```dart
return GetMaterialApp(
    translations: Messages(), // your translations
    locale: Locale('en', 'US'), // translations will be displayed in that locale
    fallbackLocale: Locale('en', 'UK'), // specify the fallback locale in case an invalid locale is selected.
);
```

#### Change locale

Call `Get.updateLocale(locale)` to update the locale. Translations then automatically use the new locale.

```dart
var locale = Locale('en', 'US');
Get.updateLocale(locale);
```

#### System locale

To read the system locale, you could use `Get.deviceLocale`.

```dart
return GetMaterialApp(
    locale: Get.deviceLocale,
);
```

## Change Theme

Please do not use any higher level widget than `GetMaterialApp` in order to update it. This can trigger duplicate keys. A lot of people are used to the prehistoric approach of creating a "ThemeProvider" widget just to change the theme of your app, and this is definitely NOT necessary with **GetXify**.

You can create your custom theme and simply add it within `Get.changeTheme` without any boilerplate for that:

```dart
Get.changeTheme(ThemeData.light());
```

If you want to create something like a button that changes the Theme in `onTap`, you can combine two **GetXify** APIs for that:

- The api that checks if the dark `Theme` is being used.
- And the `Theme` Change API, you can just put this within an `onPressed`:

```dart
Get.changeTheme(Get.isDarkMode? ThemeData.light(): ThemeData.dark());
```

When `.darkmode` is activated, it will switch to the _light theme_, and when the _light theme_ becomes active, it will change to _dark theme_.

## GetPage Middleware

The GetPage has now new property that takes a list of GetMiddleWare and run them in the specific order.

**Note**: When GetPage has a Middlewares, all the children of this page will have the same middlewares automatically.

### Priority

The Order of the Middlewares to run can be set by the priority in the GetMiddleware.

```dart
final middlewares = [
  GetMiddleware(priority: 2),
  GetMiddleware(priority: 5),
  GetMiddleware(priority: 4),
  GetMiddleware(priority: -8),
];
```

those middlewares will be run in this order **-8 => 2 => 4 => 5**

### Redirect

This function will be called when the page of the called route is being searched for. It takes RouteSettings as a result to redirect to. Or give it null and there will be no redirecting.

```dart
RouteSettings redirect(String route) {
  final authService = Get.find<AuthService>();
  return authService.authed.value ? null : RouteSettings(name: '/login')
}
```

### onPageCalled

This function will be called when this Page is called before anything created
you can use it to change something about the page or give it new page

```dart
GetPage onPageCalled(GetPage page) {
  final authService = Get.find<AuthService>();
  return page.copyWith(title: 'Welcome ${authService.UserName}');
}
```

### OnBindingsStart

This function will be called right before the Bindings are initialize.
Here you can change Bindings for this page.

```dart
List<Bindings> onBindingsStart(List<Bindings> bindings) {
  final authService = Get.find<AuthService>();
  if (authService.isAdmin) {
    bindings.add(AdminBinding());
  }
  return bindings;
}
```

### OnPageBuildStart

This function will be called right after the Bindings are initialize.
Here you can do something after that you created the bindings and before creating the page widget.

```dart
GetPageBuilder onPageBuildStart(GetPageBuilder page) {
  print('bindings are ready');
  return page;
}
```

### OnPageBuilt

This function will be called right after the GetPage.page function is called and will give you the result of the function. and take the widget that will be showed.

### OnPageDispose

This function will be called right after disposing all the related objects (Controllers, views, ...) of the page.

## Other Advanced APIs

```dart
// give the current args from currentScreen
Get.arguments

// give name of previous route
Get.previousRoute

// give the raw route to access for example, rawRoute.isFirst()
Get.rawRoute

// give access to Routing API from GetObserver
Get.routing

// check if snackbar is open
Get.isSnackbarOpen

// check if dialog is open
Get.isDialogOpen

// check if bottomsheet is open
Get.isBottomSheetOpen

// remove one route.
Get.removeRoute()

// back repeatedly until the predicate returns true.
Get.until()

// go to next route and remove all the previous routes until the predicate returns true.
Get.offUntil()

// go to next named route and remove all the previous routes until the predicate returns true.
Get.offNamedUntil()

//Check in what platform the app is running
GetPlatform.isAndroid
GetPlatform.isIOS
GetPlatform.isMacOS
GetPlatform.isWindows
GetPlatform.isLinux
GetPlatform.isFuchsia

//Check the device type
GetPlatform.isMobile
GetPlatform.isDesktop
//All platforms are supported independently in web!
//You can tell if you are running inside a browser
//on Windows, iOS, OSX, Android, etc.
GetPlatform.isWeb


// Equivalent to : MediaQuery.of(context).size.height,
// but immutable.
Get.height
Get.width

// Gives the current context of the Navigator.
Get.context

// Gives the context of the snackbar/dialog/bottomsheet in the foreground, anywhere in your code.
Get.contextOverlay

// Note: the following methods are extensions on context. Since you
// have access to context in any place of your UI, you can use it anywhere in the UI code

// If you need a changeable height/width (like Desktop or browser windows that can be scaled) you will need to use context.
context.width
context.height

// Gives you the power to define half the screen, a third of it and so on.
// Useful for responsive applications.
// param dividedBy (double) optional - default: 1
// param reducedBy (double) optional - default: 0
context.heightTransformer()
context.widthTransformer()

/// Similar to MediaQuery.sizeOf(context);
context.mediaQuerySize()

/// Similar to MediaQuery.paddingOf(context);
context.mediaQueryPadding()

/// Similar to MediaQuery.viewPaddingOf(context);
context.mediaQueryViewPadding()

/// Similar to MediaQuery.viewInsetsOf(context);
context.mediaQueryViewInsets()

/// Similar to MediaQuery.orientationOf(context);
context.orientation()

/// Check if device is on landscape mode
context.isLandscape()

/// Check if device is on portrait mode
context.isPortrait()

/// Similar to MediaQuery.devicePixelRatioOf(context);
context.devicePixelRatio()

/// Similar to MediaQuery.textScaleFactorOf(context);
context.textScaleFactor()

/// Get the shortestSide from screen
context.mediaQueryShortestSide()

/// True if width be larger than 800
context.showNavbar()

/// True if the shortestSide is smaller than 600p
context.isPhone()

/// True if the shortestSide is largest than 600p
context.isSmallTablet()

/// True if the shortestSide is largest than 720p
context.isLargeTablet()

/// True if the current device is Tablet
context.isTablet()

/// Returns a value<T> according to the screen size
/// can give value for:
/// watch: if the shortestSide is smaller than 300
/// mobile: if the shortestSide is smaller than 600
/// tablet: if the shortestSide is smaller than 1200
/// desktop: if width is largest than 1200
context.responsiveValue<T>()
```

### Optional Global Settings and Manual configurations

GetMaterialApp configures everything for you, but if you want to configure Get manually.

```dart
MaterialApp(
  navigatorKey: Get.key,
  navigatorObservers: [GetObserver()],
);
```

You will also be able to use your own Middleware within `GetObserver`, this will not influence anything.

```dart
MaterialApp(
  navigatorKey: Get.key,
  navigatorObservers: [
    GetObserver(MiddleWare.observer) // Here
  ],
);
```

You can configure `Get` directly in your `GetMaterialApp`:

```dart
GetMaterialApp(
  enableLog: true,
  defaultTransition: Transition.fade,
  opaqueRoute: Get.isOpaqueRouteDefault,
  popGesture: Get.defaultPopGesture,
  transitionDuration: Get.defaultTransitionDuration,
);
```

You can optionally redirect all the logging messages from `Get`.
If you want to use your own, favourite logging package,
and want to capture the logs there:

```dart
GetMaterialApp(
  enableLog: true,
  logWriterCallback: localLogWriter,
);

void localLogWriter(String text, {bool isError = false}) {
  // pass the message to your favourite logging package here
  // please note that even if enableLog: false log messages will be pushed in this callback
  // you get check the flag if you want through GetConfig.isLogEnable
}

```

### Local State Widgets

These Widgets allows you to manage a single value, and keep the state ephemeral and locally.
We have flavours for Reactive and Simple.
For instance, you might use them to toggle obscureText in a `TextField`, maybe create a custom
Expandable Panel, or maybe modify the current index in `BottomNavigationBar` while changing the content
of the body in a `Scaffold`.

#### ValueBuilder

A simplification of `StatefulWidget` that works with a `.setState` callback that takes the updated value.

```dart
ValueBuilder<bool>(
  initialValue: false,
  builder: (value, updateFn) => Switch(
    value: value,
    onChanged: updateFn, // same signature! you could use ( newValue ) => updateFn( newValue )
  ),
  // if you need to call something outside the builder method.
  onUpdate: (value) => print("Value updated: $value"),
  onDispose: () => print("Widget unmounted"),
),
```

#### ObxValue

Similar to [`ValueBuilder`](#valuebuilder), but this is the Reactive version, you pass a Rx instance (remember the magical .obs?) and
updates automatically... isn't it awesome?

```dart
ObxValue((data) => Switch(
        value: data.value,
        onChanged: data, // Rx has a _callable_ function! You could use (flag) => data.value = flag,
    ),
    false.obs,
),
```

## Useful tips

`.obs`ervables (also known as _Rx_ Types) have a wide variety of internal methods and operators.

> Is very common to _believe_ that a property with `.obs` **IS** the actual value... but make no mistake!
> We avoid the Type declaration of the variable, because Dart's compiler is smart enough, and the code
> looks cleaner, but:

```dart
var message = 'Hello world'.obs;
print( 'Message "$message" has Type ${message.runtimeType}');
```

Even if `message` _prints_ the actual String value, the Type is **RxString**!

So, you can't do `message.substring( 0, 4 )`.
You have to access the real `value` inside the _observable_:
The most "used way" is `.value`, but, did you know that you can also use...

```dart
final name = 'GetX'.obs;
// only "updates" the stream, if the value is different from the current one.
name.value = 'Hey';

// All Rx properties are "callable" and returns the new value.
// but this approach does not accepts `null`, the UI will not rebuild.
name('Hello');

// is like a getter, prints 'Hello'.
name() ;

/// numbers:

final count = 0.obs;

// You can use all non mutable operations from num primitives!
count + 1;

// Watch out! this is only valid if `count` is not final, but var
count += 1;

// You can also compare against values:
count > 2;

/// booleans:

final flag = false.obs;

// switches the value between true/false
flag.toggle();


/// all types:

// Sets the `value` to null.
flag.nil();

// All toString(), toJson() operations are passed down to the `value`
print( count ); // calls `toString()` inside  for RxInt

final abc = [0,1,2].obs;
// Converts the value to a json Array, prints RxList
// Json is supported by all Rx types!
print('json: ${jsonEncode(abc)}, type: ${abc.runtimeType}');

// RxMap, RxList and RxSet are special Rx types, that extends their native types.
// but you can work with a List as a regular list, although is reactive!
abc.add(12); // pushes 12 to the list, and UPDATES the stream.
abc[3]; // like Lists, reads the index 3.


// equality works with the Rx and the value, but hashCode is always taken from the value
final number = 12.obs;
print( number == 12 ); // prints > true

/// Custom Rx Models:

// toJson(), toString() are deferred to the child, so you can implement override on them, and print() the observable directly.

class User {
    String name, last;
    int age;
    User({this.name, this.last, this.age});

    @override
    String toString() => '$name $last, $age years old';
}

final user = User(name: 'John', last: 'Doe', age: 33).obs;

// `user` is "reactive", but the properties inside ARE NOT!
// So, if we change some variable inside of it...
user.value.name = 'Roi';
// The widget will not rebuild!,
// `Rx` don't have any clue when you change something inside user.
// So, for custom classes, we need to manually "notify" the change.
user.refresh();

// or we can use the `update()` method!
user.update((value){
  value.name='Roi';
});

print( user );
```

## StateMixin

Another way to handle your `UI` state is use the `StateMixin<T>` .
To implement it, use the `with` to add the `StateMixin<T>`
to your controller which allows a T model.

```dart
class Controller extends GetController with StateMixin<User>{}
```

The `change()` method change the State whenever we want.
Just pass the data and the status in this way:

```dart
change(data, status: RxStatus.success());
```

RxStatus allow these status:

```dart
RxStatus.loading();
RxStatus.success();
RxStatus.empty();
RxStatus.error('message');
```

To represent it in the UI, use:

```dart
class OtherClass extends GetView<Controller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: controller.obx(
        (state)=>Text(state.name),

        // here you can put your custom loading indicator, but
        // by default would be Center(child:CircularProgressIndicator())
        onLoading: CustomLoadingIndicator(),
        onEmpty: Text('No data found'),

        // here also you can set your own error widget, but by
        // default will be an Center(child:Text(error))
        onError: (error)=>Text(error),
      ),
    );
}
```

#### GetView

I love this Widget, is so simple, yet, so useful!

Is a `const Stateless` Widget that has a getter `controller` for a registered `Controller`, that's all.

```dart
 class AwesomeController extends GetController {
   final String title = 'My Awesome View';
 }

  // ALWAYS remember to pass the `Type` you used to register your controller!
 class AwesomeView extends GetView<AwesomeController> {
   @override
   Widget build(BuildContext context) {
     return Container(
       padding: EdgeInsets.all(20),
       child: Text(controller.title), // just call `controller.something`
     );
   }
 }
```

#### GetResponsiveView

Extend this widget to build responsive view.
this widget contains the `screen` property that have all
information about the screen size and type.

##### How to use it

You have two options to build it.

- with `builder` method you return the widget to build.
- with methods `desktop`, `tablet`,`phone`, `watch`. the specific
  method will be built when the screen type matches the method
  when the screen is [ScreenType.Tablet] the `tablet` method
  will be exuded and so on.
  **Note:** If you use this method please set the property `alwaysUseBuilder` to `false`

With `settings` property you can set the width limit for the screen types.

![example](https://github.com/SchabanBo/get_page_example/blob/master/docs/Example.gif?raw=true)
Code to this screen
[code](https://github.com/SchabanBo/get_page_example/blob/master/lib/pages/responsive_example/responsive_view.dart)

#### GetWidget

Most people have no idea about this Widget, or totally confuse the usage of it.
The use case is very rare, but very specific: It `caches` a Controller.
Because of the _cache_, can't be a `const Stateless`.

> So, when do you need to "cache" a Controller?

If you use, another "not so common" feature of **GetXify**: `Get.create()`.

`Get.create(()=>Controller())` will generate a new `Controller` each time you call
`Get.find<Controller>()`,

That's where `GetWidget` shines... as you can use it, for example,
to keep a list of Todo items. So, if the widget gets "rebuilt", it will keep the same controller instance.

#### GetxService

This class is like a `GetxController`, it shares the same lifecycle ( `onInit()`, `onReady()`, `onClose()`).
But has no "logic" inside of it. It just notifies **GetXify** Dependency Injection system, that this subclass
**can not** be removed from memory.

So is super useful to keep your "Services" always reachable and active with `Get.find()`. Like:
`ApiService`, `StorageService`, `CacheService`.

```dart
Future<void> main() async {
  await initServices(); /// AWAIT SERVICES INITIALIZATION.
  runApp(SomeApp());
}

/// Is a smart move to make your Services initialize before you run the Flutter app.
/// as you can control the execution flow (maybe you need to load some Theme configuration,
/// apiKey, language defined by the User... so load SettingService before running ApiService.
/// so GetMaterialApp() doesnt have to rebuild, and takes the values directly.
void initServices() async {
  print('starting services ...');
  /// Here is where you put get_storage, hive, shared_pref initialization.
  /// or moor connection, or whatever that's async.
  await Get.putAsync(() => DbService().init());
  await Get.putAsync(SettingsService()).init();
  print('All services started...');
}

class DbService extends GetxService {
  Future<DbService> init() async {
    print('$runtimeType delays 2 sec');
    await 2.delay();
    print('$runtimeType ready!');
    return this;
  }
}

class SettingsService extends GetxService {
  void init() async {
    print('$runtimeType delays 1 sec');
    await 1.delay();
    print('$runtimeType ready!');
  }
}

```

The only way to actually delete a `GetxService`, is with `Get.reset()` which is like a
"Hot Reboot" of your app. So remember, if you need absolute persistence of a class instance during the
lifetime of your app, use `GetxService`.

### Tests

You can test your controllers like any other class, including their lifecycles:

```dart
class Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    //Change value to name2
    name.value = 'name2';
  }

  @override
  void onClose() {
    name.value = '';
    super.onClose();
  }

  final name = 'name1'.obs;

  void changeName() => name.value = 'name3';
}

void main() {
  test('''
Test the state of the reactive variable "name" across all of its lifecycles''',
      () {
    /// You can test the controller without the lifecycle,
    /// but it's not recommended unless you're not using
    ///  GetX dependency injection
    final controller = Controller();
    expect(controller.name.value, 'name1');

    /// If you are using it, you can test everything,
    /// including the state of the application after each lifecycle.
    Get.put(controller); // onInit was called
    expect(controller.name.value, 'name2');

    /// Test your functions
    controller.changeName();
    expect(controller.name.value, 'name3');

    /// onClose was called
    Get.delete<Controller>();

    expect(controller.name.value, '');
  });
}
```

#### Tips

##### Mockito or mocktail

If you need to mock your GetxController/GetxService, you should extend GetxController, and mixin it with Mock, that way

```dart
class NotificationServiceMock extends GetxService with Mock implements NotificationService {}
```

##### Using Get.reset()

If you are testing widgets, or test groups, use Get.reset at the end of your test or in tearDown to reset all settings from your previous test.

##### Get.testMode

if you are using your navigation in your controllers, use `Get.testMode = true` at the beginning of your main.

# Contributing

Contributions are welcome! If you find a bug or want to add a new feature, please feel free to submit a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and follow the existing code style.

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
