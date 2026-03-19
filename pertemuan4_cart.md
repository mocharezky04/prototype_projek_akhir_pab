# 📱 PERTEMUAN 4

## State Management dengan Provider

---

## 🎯 Tujuan Pembelajaran

Setelah mengikuti pertemuan ini, Anda diharapkan mampu:

1. ✅ Menjelaskan perbedaan ephemeral state dan app state
2. ✅ Menggunakan setState untuk state lokal
3. ✅ Memahami keterbatasan setState
4. ✅ Mengimplementasikan Provider untuk app state
5. ✅ Membuat ChangeNotifier class
6. ✅ Membangun shopping cart dengan Provider

---

## ⏱️ TIMELINE SESI (Total: 150 menit)

| Durasi   | Topik  | Aktivitas                              |
| -------- | ------ | -------------------------------------- |
| 10 menit | Part 0 | Review & Warm Up                       |
| 15 menit | Part 1 | Understanding State (Ephemeral vs App) |
| 20 menit | Part 2 | setState dan Keterbatasannya           |
| 10 menit | Part 3 | Introduction to Provider               |
| 25 menit | Part 4 | ChangeNotifier Pattern                 |
| 50 menit | Part 5 | Shopping Cart Hands-On (MAIN PROJECT)  |
| 15 menit | Part 6 | Advanced Provider Topics               |
| 5 menit  | Part 7 | Wrap Up + Praktikum briefing           |

---

## 📂 RESOURCES

> 💡 **File demo tersedia di folder `contoh_kode/pertemuan_4/`**

| File                                   | Deskripsi                                  |
| -------------------------------------- | ------------------------------------------ |
| `01_counter_setstate_demo.dart`      | Counter dengan setState (baseline)         |
| `02_prop_drilling_problem_demo.dart` | Problem: passing state 3 levels deep       |
| `03_counter_provider_demo.dart`      | Counter solution dengan Provider           |
| `04_shopping_cart_complete.dart`     | Shopping cart lengkap (praktikum solution) |
| `05_multi_provider_demo.dart`        | Multiple providers (Cart + User + Theme)   |
| `06_selector_optimization_demo.dart` | Selector untuk performance optimization    |

---

## 📋 PERSIAPAN SEBELUM MEMULAI

- ✅ Flutter SDK terinstall
- ✅ Editor (VS Code / Android Studio) ready
- ✅ Device / emulator running
- ✅ Review materi Pertemuan 3 (Navigation, passing data)
- ✅ Install provider package: `flutter pub add provider`

---

## 🔄 PART 0: Review & Warm Up (10 menit)

### Quick Quiz (5 menit)

**Jawab pertanyaan berikut untuk check understanding:**

1. **Apa bedanya Navigator.push dan Navigator.pop?**
2. **Bagaimana cara pass data ke halaman baru?**
3. **Bagaimana cara return value dari halaman yang ditutup?**
4. **Apa fungsi setState dalam StatefulWidget?**
5. **Kapan widget akan rebuild?**

> 💡 **JANGAN LANJUT** sebelum yakin paham basic state management dengan setState!

### Today's Challenge: The State Problem (5 menit)

**Scenario:**

> Bayangkan kamu buat aplikasi **shopping cart**:
>
> - Product list page perlu show items
> - Cart badge di AppBar perlu show jumlah items
> - Cart page perlu show detail items
> - Cart page perlu update quantity
> - All pages share **SAME cart data**

**Question**: Gimana caranya semua page bisa akses cart yang SAMA? 🤔

**Bad Solution** (yang akan kita hindari):

```dart
HomePage(cart: myCart, onAdd: () {...})
  └─> ProductPage(cart: myCart, onAdd: () {...})
      └─> DetailPage(cart: myCart, onAdd: () {...})
          └─> CartPage(cart: myCart, onUpdate: () {...})
```

Pass cart ke SEMUA widget? 😱 **NIGHTMARE!**

**Good Solution** (yang akan kita pelajari):

```dart
Provider<CartModel> ← ONE source
    ├─> HomePage ← read cart
    ├─> ProductPage ← read cart
    ├─> DetailPage ← add to cart
    └─> CartPage ← manage cart
```

Semua widget akses cart langsung! 🎉

---

## 💡 PART 1: Understanding State (15 menit)

### Konsep Dasar: Apa itu State?

**State** = Data yang bisa berubah dan mempengaruhi tampilan UI.

**Contoh State**:

- Counter value (0, 1, 2, ...)
- Login status (logged in / logged out)
- Shopping cart items
- Form input values
- Dark mode on/off

**2 Jenis State:**

```
┌────────────────────┬─────────────────────┐
│  Ephemeral State   │    App State        │
├────────────────────┼─────────────────────┤
│ Local to 1 widget  │ Shared across app   │
│ setState()         │ Provider/Riverpod   │
│ Dies on navigate   │ Persists in app     │
│ Example: TextField │ Example: Cart       │
└────────────────────┴─────────────────────┘
```

### 💡 ANALOGI: State seperti Catatan

> **Ephemeral State** = Sticky note di mejamu
>
> - Hanya kamu yang akses
> - Hilang kalau pindah meja
> - Contoh: Draft email yang belum dikirim
>
> **App State** = Whiteboard di ruang meeting
>
> - Semua orang lihat
> - Tetap ada meskipun orang keluar-masuk
> - Contoh: Todo list tim

### 🎯 EKSPERIMEN 1: Ephemeral State - Counter Demo (7 menit)

Mari buat counter sederhana dengan setState!

**Create new file**: `lib/pages/counter_page.dart`

```dart
// lib/pages/counter_page.dart
import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // Ephemeral state - local to this widget
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++; // Modify state
    }); // Trigger rebuild
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('CounterPage rebuilt!'); // ← We'll see this print

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter with setState'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _increment,
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Update main.dart**:

```dart
import 'package:flutter/material.dart';
import 'pages/counter_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pertemuan 4 - State Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CounterPage(),
    );
  }
}
```

**Hot Reload!** Klik tombol Increment → Counter naik!

**💡 YANG TERJADI**:

1. User tap button → `_increment()` dipanggil
2. `setState(() { _counter++; })` → Modify state + mark dirty
3. Flutter rebuild widget
4. `build()` dipanggil lagi → UI update dengan nilai baru

**setState SANGAT COCOK untuk:**

- ✅ Local widget state (form input, checkbox)
- ✅ Simple counter, toggle
- ✅ Animation state
- ✅ UI-only state (expanded/collapsed)

### 🎯 EKSPERIMEN 2: App State Problem - Sharing Between Pages (8 menit)

**Task**: Tampilkan counter di 2 halaman berbeda!

**Create**: `lib/pages/counter_display_page.dart`

```dart
// lib/pages/counter_display_page.dart
import 'package:flutter/material.dart';

class CounterDisplayPage extends StatelessWidget {
  final int counter; // ← Need counter dari parent!

  const CounterDisplayPage({
    super.key,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Counter value from HomePage:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              '$counter',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '⚠️ But I can\'t increment it here!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Update CounterPage** dengan navigation button:

```dart
// Di dalam build method, tambahkan di Column setelah Row
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CounterDisplayPage(
          counter: _counter, // ← Pass counter value
        ),
      ),
    );
  },
  icon: const Icon(Icons.arrow_forward),
  label: const Text('View Counter'),
),
```

**Hot Reload & Test!**

1. Increment counter di HomePage (mis: 5)
2. Klik "View Counter" → Muncul 5 ✓
3. Back ke HomePage
4. Ke DisplayPage lagi → Still 5 ✓

**Tapi... MASALAH**:

```
❌ CounterDisplayPage can't increment counter
❌ Need to pass callback: onIncrement
❌ Multiple pages = many parameters
❌ Deep nesting = NIGHTMARE
```

**Visualisasi Masalah**:

```
CounterPage (_counter: 5)
      │
      ├─> Display value: ✓ Easy
      │
      └─> Navigate to DisplayPage(counter: 5)
              │
              └─> Display: ✓ Works
                  Increment: ❌ Can't! No setState here
```

**💡 MASALAH INI DISEBUT**: **Prop Drilling** atau **State Lifting Problem**

> ⚠️ **PROBLEM YANG MUNCUL**:
>
> **Problem**: "Too many parameters to pass"
>
> - **Symptom**: Constructor jadi panjang dengan banyak callbacks
> - **Worse**: Deep widgets (3+ levels) susah akses data dari top
> - **Result**: Code jadi messy, hard to maintain
> - **Example**: Cart harus di-pass ke 10 widget berbeda!

### 💡 Tips & Best Practices - Kapan Pakai setState

**DO ✅:**

- Gunakan setState untuk state LOCAL (1 widget)
- State yang bersifat sementara (UI state)
- Simple toggle, checkbox, text input
- State yang tidak perlu di-share

**DON'T ❌:**

- Jangan pakai setState untuk state yang di-share >2 widgets
- Jangan pass state through 3+ levels (prop drilling)
- Jangan duplicate state di multiple widgets
- Jangan pakai untuk app-wide data (cart, user, theme)

**KAPAN PINDAH KE PROVIDER?**

- State perlu diakses >2 pages
- Banyak widgets perlu same state
- State complex (cart with add/remove/update)
- State persist selama app lifetime

---

## 🔗 PART 2: setState dan Keterbatasannya (20 menit)

### The Prop Drilling Problem

Saat app tumbuh besar, setState punya masalah serius: **Prop Drilling**.

**💡 ANALOGI - Telepon Beranting**:

```
Boss → Manager → Supervisor → Team Lead → Worker

Boss bilang: "Increase salary"
Harus lewat 4 orang!
Kalau Manager lupa pass? FAIL!
```

### ✏️ CODING BERSAMA: Prop Drilling Hell Demo (15 menit)

Mari buat app yang show masalah prop drilling!

**Step 1: Create HomePage with counter** (3 menit)

```dart
// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() {
    setState(() => _counter++);
  }

  void _reset() {
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Badge showing counter
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$_counter',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter: $_counter',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _increment,
              child: const Text('Increment'),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      counter: _counter,      // ← Pass counter
                      onReset: _reset,        // ← Pass callback
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Create ProfilePage (needs counter from HomePage)** (4 menit)

```dart
// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  final int counter;           // ← Receive from HomePage
  final VoidCallback onReset;  // ← Receive callback

  const ProfilePage({
    super.key,
    required this.counter,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Points: $counter', // ← Use counter here!
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      counter: counter,    // ← Pass again!
                      onReset: onReset,    // ← Pass again!
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 3: Create SettingsPage (needs reset from HomePage!)** (5 menit)

```dart
// lib/pages/settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final int counter;           // ← Receive from Profile (from Home!)
  final VoidCallback onReset;  // ← Receive from Profile (from Home!)

  const SettingsPage({
    super.key,
    required this.counter,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 80),
            const SizedBox(height: 20),
            Text(
              'Current Points: $counter',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                onReset(); // ← Call callback 2 levels deep!
                Navigator.pop(context);
                Navigator.pop(context); // Back to home
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Points'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '⚠️ This is 2 levels deep from HomePage!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Hot Reload & Test!**

Flow: Home → Profile → Settings → Reset → Back to Home

**LIHATLAH MASALAHNYA:**

```
HomePage (has _counter, _reset)
   │
   ├─ Pass counter + onReset
   ↓
ProfilePage (doesn't use onReset, just pass it!)
   │
   ├─ Pass counter + onReset AGAIN
   ↓
SettingsPage (finally uses onReset!)
```

**📊 Visualisasi Prop Drilling**:

```
┌────────────────────────────────┐
│ HomePage                       │
│ _counter: 5                    │
│ _increment(), _reset()         │
└────────────┬───────────────────┘
             │ Pass counter + onReset
             ↓
┌────────────────────────────────┐
│ ProfilePage                    │
│ Just displays counter          │
│ Doesn't use onReset!           │ ← WASTE!
└────────────┬───────────────────┘
             │ Pass counter + onReset AGAIN
             ↓
┌────────────────────────────────┐
│ SettingsPage                   │
│ Finally uses onReset()         │
└────────────────────────────────┘

Problem: ProfilePage is just a "courier"!
```

### 🎯 EKSPERIMEN 3: Count Rebuilds (3 menit)

Add print statements to see rebuilds:

```dart
// In HomePage build():
@override
Widget build(BuildContext context) {
  print('🔴 HomePage rebuilt!');
  return Scaffold(...);
}

// In ProfilePage build():
@override
Widget build(BuildContext context) {
  print('🟡 ProfilePage rebuilt!');
  return Scaffold(...);
}

// In SettingsPage build():
@override
Widget build(BuildContext context) {
  print('🟢 SettingsPage rebuilt!');
  return Scaffold(...);
}
```

**Test**: Increment di HomePage → Check console

Result:

```
🔴 HomePage rebuilt!
```

Only HomePage rebuilds! ✓ Good.

**But imagine**:

- 10 pages need counter
- 5 pages need reset function
- Constructor parameters = NIGHTMARE 😱

> ⚠️ **TROUBLESHOOTING - setState Limitations**:
>
> **Problem**: "Too many constructor parameters"
>
> - **Cause**: Passing state through multiple levels
> - **Impact**: Code hard to read, maintain, test
> - **Sign**: Widget has >3 parameters just for passing data
>
> **Problem**: "Widget doesn't use data but needs to pass it"
>
> - **Cause**: Prop drilling (middle widget just courier)
> - **Impact**: Tight coupling, hard to refactor
> - **Example**: ProfilePage doesn't use onReset but must pass it
>
> **Problem**: "Duplicate state in multiple widgets"
>
> - **Cause**: Each widget has own copy of state
> - **Impact**: State out of sync, bugs
> - **Sign**: Same data stored in 2+ places

### 💡 Tips & Best Practices - When setState Fails

**setState FAILS when:**

- ❌ State needed in >2 widgets
- ❌ Widgets tidak direct parent-child
- ❌ Deep nesting (3+ levels)
- ❌ State complex (cart, user profile)

**SIGNS you need better state management:**

- 🚩 Constructor has >5 parameters
- 🚩 Passing callbacks 3+ levels deep
- 🚩 Widget just "passes through" data
- 🚩 Duplicate setState in multiple widgets
- 🚩 Hard to test because of coupling

**SOLUTION**: Provider! 🎉

---

## 📦 PART 3: Introduction to Provider (10 menit)

### What is Provider?

**Provider** adalah state management solution **officially recommended** oleh Flutter team.

**💡 ANALOGI - Provider seperti WiFi Router**:

```
❌ WITHOUT Provider (Cables):      ✅ WITH Provider (WiFi):
┌────────┐                        ┌─────────────┐
│ Phone  ├──cable──┐              │   Router    │
└────────┘         │              │ (Provider)  │
┌────────┐         │              └──────┬──────┘
│ Laptop ├──cable──┤               📡   │   📡
└────────┘         │              ┌──────┴──────┐
┌────────┐         │              ↓             ↓
│ Tablet ├──cable──┘          Phone          Laptop
└────────┘                    (Consumer)     (Consumer)

Many cables!                  Wireless access!
Hard to add device!          Easy to add new listener!
```

### Why Provider?

| Feature            | setState         | Provider          |
| ------------------ | ---------------- | ----------------- |
| **Scope**    | Local (1 widget) | App-wide          |
| **Sharing**  | Via parameters   | Direct access     |
| **Rebuilds** | Entire widget    | Only listeners    |
| **Testing**  | Hard (coupled)   | Easy (injectable) |
| **Code**     | Prop drilling    | Clean             |
| **Official** | ✓ Built-in      | ✓ Recommended    |

### Provider Benefits

1. ✅ **No Prop Drilling** - Access state from anywhere
2. ✅ **Efficient Rebuilds** - Only listeners rebuild
3. ✅ **Separation of Concerns** - Business logic separate from UI
4. ✅ **Testable** - Easy to mock and test
5. ✅ **Official** - Recommended by Flutter team
6. ✅ **Built on InheritedWidget** - Fast and reliable

### 📦 Installation (3 menit)

**Step 1**: Add dependency ke `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0 # ← ADD THIS LINE
```

**Step 2**: Install package

Terminal/Command Prompt:

```bash
flutter pub get
```

Atau shortcut:

```bash
flutter pub add provider
```

**Step 3**: Verify installation

Cek `pubspec.lock` → should see `provider: 6.1.0` (or latest)

**Step 4**: Import in code

```dart
import 'package:provider/provider.dart';
```

Done! 🎉

### How Provider Works

**Konsep dasar**:

```
1. CREATE model class (holds state)
   ↓
2. PROVIDE at app level (make available)
   ↓
3. CONSUME anywhere (listen to changes)
   ↓
4. UPDATE state → Notify listeners
   ↓
5. UI rebuilds automatically!
```

**Visualisasi**:

```
Provider<CounterModel>
       ↓
  MaterialApp
       │
┌──────┼──────┐
│      │      │
Home  Profile Settings
│      │      │
└──────┴──────┘
    All can access CounterModel!
    No passing parameters!
```

### Provider vs Other Solutions

| Solution           | Complexity | Learning Curve | Use Case    |
| ------------------ | ---------- | -------------- | ----------- |
| **setState** | ⭐         | Easy           | Local state |
| **Provider** | ⭐⭐       | Medium         | App state   |
| **Riverpod** | ⭐⭐⭐     | Hard           | Large apps  |
| **Bloc**     | ⭐⭐⭐⭐   | Very Hard      | Enterprise  |
| **GetX**     | ⭐⭐       | Medium         | All-in-one  |

**Recommendation**: Start dengan Provider! Official + Cukup powerful + Not too complex.

### Next: ChangeNotifier Pattern

Di Part 4, kita akan belajar **ChangeNotifier** - core pattern di Provider!

**Sneak peek**:

```dart
class CounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // ← Magic happens here!
  }
}
```

Simple kan? Let's go! 🚀

---

## 🔔 PART 4: ChangeNotifier Pattern (25 menit)

### What is ChangeNotifier?

**ChangeNotifier** adalah class yang:

- Menyimpan state
- Notify listeners saat state berubah
- Pattern: **Observable** (observers listen to changes)

**💡 ANALOGI - ChangeNotifier seperti Alarm/Bell**:

```
Teacher (ChangeNotifier) has a bell 🔔
Students (Listeners) are working
When teacher rings bell → All students look up!

ChangeNotifier.notifyListeners() = Ring bell 🔔
Consumers = Students that listen
State change = New announcement
```

### ✏️ CODING BERSAMA: Counter with Provider (20 menit)

Mari rebuild counter app dengan Provider!

**Step 1: Create CounterModel** (5 menit)

Create folder `lib/models/` dan file `counter_model.dart`:

```dart
// lib/models/counter_model.dart
import 'package:flutter/foundation.dart';

class CounterModel extends ChangeNotifier {
  // 1. Private state variable
  int _count = 0;

  // 2. Public getter for read access
  int get count => _count;

  // 3. Public methods to modify state
  void increment() {
    _count++;                // Modify state
    notifyListeners();       // ← CRUCIAL! Notify all listeners
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }

  // Optional: method dengan parameter
  void addValue(int value) {
    _count += value;
    notifyListeners();
  }
}
```

**💡 PATTERN BREAKDOWN**:

```
┌────────────────────────────────────┐
│ class CounterModel                 │
│ extends ChangeNotifier             │ ← Magic!
├────────────────────────────────────┤
│ int _count = 0;                    │ ← Private state
│ int get count => _count;           │ ← Public getter (read-only)
├────────────────────────────────────┤
│ void increment() {                 │
│   _count++;                        │ ← Modify
│   notifyListeners();               │ ← Notify! 🔔
│ }                                  │
└────────────────────────────────────┘

Rule: ALWAYS call notifyListeners() after state change!
```

**Step 2: Provide at App Level** (3 menit)

Update `main.dart`:

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/counter_model.dart';
import 'pages/counter_page.dart'; // File yang dibuat di Part 1 (Step 3)

void main() {
  runApp(
    // Wrap MaterialApp with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => CounterModel(), // ← Create instance once
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CounterProviderPage(),
    );
  }
}
```

**💡 KEY POINTS**:

- `ChangeNotifierProvider` membuat CounterModel available ke semua widgets di bawahnya
- `create` function dipanggil ONCE saat app start
- Semua child widgets bisa akses CounterModel!

**Step 3: Consume with Consumer** (7 menit)

Create `lib/pages/counter_provider_page.dart`:

```dart
// lib/pages/counter_provider_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/counter_model.dart';

class CounterProviderPage extends StatelessWidget {
  const CounterProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔴 CounterProviderPage build'); // We'll see this ONCE

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter with Provider'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Consumer - Only THIS widget rebuilds!
            Consumer<CounterModel>(
              builder: (context, counter, child) {
                print('🟢 Consumer rebuilt!'); // Only this prints on change
                return Text(
                  '${counter.count}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Use context.read to trigger action
                    context.read<CounterModel>().increment();
                  },
                  child: const Text('Increment'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CounterModel>().decrement();
                  },
                  child: const Text('Decrement'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CounterModel>().reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Hot Reload!** Tap Increment → Counter updates!

**💡 WHAT HAPPENS**:

```
1. User taps "Increment" button
   ↓
2. context.read<CounterModel>().increment() called
   ↓
3. CounterModel._count++ executed
   ↓
4. notifyListeners() called
   ↓
5. All Consumers listening to CounterModel rebuild
   ↓
6. Only Consumer widget rebuilds, NOT entire page!
   ↓
7. UI shows new count value
```

**Step 4: Alternative - Using context.watch** (5 menit)

You can also use `context.watch` (simpler but rebuilds more):

```dart
// Alternative to Consumer
@override
Widget build(BuildContext context) {
  // Watch for changes - rebuilds ENTIRE widget
  final counter = context.watch<CounterModel>();

  return Scaffold(
    body: Center(
      child: Text('${counter.count}'),
    ),
  );
}
```

**Consumer vs context.watch**:

| Method            | Rebuild Scope        | Use Case                              |
| ----------------- | -------------------- | ------------------------------------- |
| `Consumer`      | Only Consumer widget | Targeted rebuild (better performance) |
| `context.watch` | Entire build method  | Simple cases, small widgets           |
| `context.read`  | No rebuild           | Callbacks, event handlers only        |

### 🎯 EKSPERIMEN 4: Compare Rebuilds (5 menit)

**Test**: Add print statements dan lihat perbedaan!

```dart
// Using Consumer (BETTER)
Consumer<CounterModel>(
  builder: (context, counter, child) {
    print('Consumer rebuilt'); // ← Only this prints
    return Text('${counter.count}');
  },
)

// vs

// Using context.watch
final counter = context.watch<CounterModel>();
print('Entire widget rebuilt'); // ← Entire widget rebuilds!
return Text('${counter.count}');
```

**Result**: Consumer lebih efficient! Only rebuild what's needed.

> ⚠️ **TROUBLESHOOTING - ChangeNotifier**:
>
> **Problem**: "Could not find the correct Provider`<CounterModel>`"
>
> - **Cause**: ChangeNotifierProvider tidak di atas widget yang consume
> - **Fix**: Move ChangeNotifierProvider di main.dart, wrap MaterialApp
> - **Verify**: Provider harus di parent/ancestor dari Consumer
>
> **Problem**: "UI tidak update saat state berubah"
>
> - **Cause**: Lupa call `notifyListeners()`
> - **Fix**: Add `notifyListeners()` setelah every state change
> - **Pattern**: Always `_field++; notifyListeners();`
>
> **Problem**: "context.read used inside build method"
>
> - **Cause**: Trying to read inside build (should watch/Consumer)
> - **Fix**: Use `context.watch` or `Consumer` in build, `read` in callbacks
> - **Rule**: read = callbacks, watch = build

### 💡 Tips & Best Practices - ChangeNotifier

**DO ✅:**

- Extend ChangeNotifier untuk model classes
- Use private fields (`_count`) dengan public getters
- ALWAYS call notifyListeners() after state change
- Use Consumer untuk targeted rebuilds
- Use context.read di callbacks/event handlers
- Create separate model classes (not in widgets)

**DON'T ❌:**

- Don't forget notifyListeners() (most common mistake!)
- Don't use context.read inside build method
- Don't modify state without notifying
- Don't create multiple instances (use Provider)
- Don't dispose manually (Provider handles it)
- Don't call notifyListeners() in getter

**PATTERN TEMPLATE**:

```dart
class MyModel extends ChangeNotifier {
  // Private state
  Type _field = initialValue;

  // Public getter
  Type get field => _field;

  // Public methods
  void updateField(newValue) {
    _field = newValue;
    notifyListeners(); // ← ALWAYS!
  }
}
```

---

## 🛒 PART 5: Shopping Cart Hands-On (50 menit)

### 🎯 Project Goal

Build **Mini E-Commerce Shopping Cart** dengan Provider!

**Features Checklist**:

- [ ] Product model
- [ ] Cart model with ChangeNotifier
- [ ] Product list page
- [ ] Add to cart button
- [ ] Cart badge showing item count
- [ ] Cart page with all items
- [ ] Increase/decrease quantity
- [ ] Remove item button
- [ ] Total price calculation
- [ ] Empty cart message

### ✏️ CODING BERSAMA: Shopping Cart (45 menit)

**Step 1: Create Product Model** (5 menit)

```dart
// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String emoji;      // ← Emoji sebagai gambar produk (offline-friendly!)
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
    required this.description,
  });
}
```

> 💡 **Kenapa emoji?** Lebih simple, tidak perlu internet, dan mudah diubah ke `Image.network` nanti di Pertemuan 6 (Networking)!

**Step 2: Create CartItem Model** (3 menit)

```dart
// lib/models/cart_item.dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Calculated property
  double get totalPrice => product.price * quantity;
}
```

**Step 3: Create CartModel with ChangeNotifier** (12 menit)

```dart
// lib/models/cart_model.dart
import 'package:flutter/foundation.dart';
import 'product.dart';
import 'cart_item.dart';

class CartModel extends ChangeNotifier {
  // Private state - Map for O(1) lookup
  final Map<String, CartItem> _items = {};

  // Getters
  Map<String, CartItem> get items => _items;

  List<CartItem> get itemsList => _items.values.toList();

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isEmpty => _items.isEmpty;

  // Methods
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Product already in cart, increase quantity
      _items[product.id]!.quantity++;
    } else {
      // New product, add to cart
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners(); // ← Notify UI!
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      // If quantity becomes 0, remove item
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```

**💡 CODE EXPLANATION**:

- `Map<String, CarItem>` untuk fast lookup by product ID
- `fold()` untuk calculate totals efficiently
- Every method calls `notifyListeners()` after modifying state
- Getter tidak call notifyListeners (read-only!)

**Step 4: Update main.dart with CartModel Provider** (3 menit)

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'pages/product_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProductListPage(),
    );
  }
}
```

**Step 5: Create Product List Page** (10 menit)

```dart
// lib/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_page.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy products
    final products = [
      Product(
        id: '1',
        name: 'Laptop Gaming',
        price: 15000000,
        emoji: '💻',
        description: 'Laptop gaming performa tinggi',
      ),
      Product(
        id: '2',
        name: 'Smartphone Pro',
        price: 8000000,
        emoji: '📱',
        description: 'Smartphone flagship terbaru',
      ),
      Product(
        id: '3',
        name: 'Wireless Headphones',
        price: 1500000,
        emoji: '🎧',
        description: 'Headphones noise-cancelling',
      ),
      Product(
        id: '4',
        name: 'Smart Watch',
        price: 3000000,
        emoji: '⌚',
        description: 'Smartwatch dengan health tracking',
      ),
      Product(
        id: '5',
        name: 'Camera DSLR',
        price: 12000000,
        emoji: '📷',
        description: 'Kamera DSLR profesional',
      ),
      Product(
        id: '6',
        name: 'Tablet Pro',
        price: 7000000,
        emoji: '📟',
        description: 'Tablet untuk produktivitas',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Cart badge
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 3,
            child: Column(
              children: [
              children: [
                Expanded(
                  child: Container(
                    color: Colors.deepPurple.shade50,
                    child: Center(
                      child: Text(
                        product.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add to cart using Provider!
                            context.read<CartModel>().addItem(product);

                            // Show feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} ditambahkan ke cart!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

**Hot Reload!** Product grid muncul + Cart badge works!

---

**Step 6: Create Cart Page** (12 menit)

```dart
// lib/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // Clear cart button
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return cart.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear Cart?'),
                            content: const Text('Remove all items from cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<CartModel>().clear();
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.itemsList.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.itemsList[index];
                    final product = cartItem.product;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            // Product emoji
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity controls
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cart.decreaseQuantity(product.id);
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          cart.increaseQuantity(product.id);
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Remove button & subtotal
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cart.removeItem(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} removed'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                                Text(
                                  'Rp ${cartItem.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total price bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Rp ${cart.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Checkout action
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Checkout'),
                              content: Text(
                                'Total: Rp ${cart.totalPrice.toStringAsFixed(0)}\nItems: ${cart.totalQuantity}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    cart.clear();
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order placed!')),
                                    );
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

**Hot Reload & Test!** Full shopping cart working! 🎉

### 🎯 EKSPERIMEN 5: Test Cart Operations (5 menit)

**Try these operations**:

1. Add product 3x → Quantity should be 3 ✓
2. Add different products → Badge shows count ✓
3. Increase quantity → Updates price ✓
4. Decrease to 1 → Still in cart ✓
5. Decrease to 0 → Removed from cart ✓
6. Clear all → Empty cart message ✓
7. Navigate back → Badge still correct ✓

**No prop drilling! All pages access same CartModel!** 🎉

---

## 🚀 PART 6: Advanced Provider Topics (15 menit)

### Topic 1: MultiProvider (4 menit)

Kalau app punya multiple state objects:

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Akses semua providers**:

```dart
final cart = context.watch<CartModel>();
final user = context.watch<UserModel>();
final theme = context.watch<ThemeModel>();
```

### Topic 2: Consumer vs context.watch vs context.read (6 menit)

**Comparison Table**:

| Method                  | Rebuild                | Use in build() | Use in callback | Best For                |
| ----------------------- | ---------------------- | -------------- | --------------- | ----------------------- |
| **Consumer**      | ✅ Yes (optimized)     | ✅ Yes         | ❌ No           | Specific widget rebuild |
| **context.watch** | ✅ Yes (entire widget) | ✅ Yes         | ❌ No           | Simple cases            |
| **context.read**  | ❌ No                  | ❌ No          | ✅ Yes          | Triggering actions      |

**Examples**:

```dart
// 1. Consumer - Best for targeted rebuilds
Consumer<CartModel>(
  builder: (context, cart, child) {
    return Text('Items: ${cart.itemCount}');
  },
)

// 2. context.watch - Simple but less efficient
@override
Widget build(BuildContext context) {
  final cart = context.watch<CartModel>();
  return Text('Items: ${cart.itemCount}');
}

// 3. context.read - For callbacks ONLY
ElevatedButton(
  onPressed: () {
    context.read<CartModel>().clear(); // ✓ Correct
  },
)

// ❌ WRONG - Don't use read in build
@override
Widget build(BuildContext context) {
  final cart = context.read<CartModel>(); // ❌ Error!
  return Text('${cart.itemCount}');
}
```

### Topic 3: Selector - Performance Optimization (5 menit)

**Problem**: Consumer rebuilds even if you only need one field!

**Solution**: Use `Selector`!

```dart
// Rebuild only when itemCount changes, NOT totalPrice
Selector<CartModel, int>(
  selector: (context, cart) => cart.itemCount,
  builder: (context, itemCount, child) {
    return Text('Items: $itemCount');
  },
)
```

**When to use**:

- Large model with many fields
- Widget only needs specific field
- Frequent updates to model

### 💡 Tips & Best Practices - Provider Optimization

**DO ✅:**

- Use Consumer for targeted rebuilds
- Use context.read in callbacks
- Use Selector when model is large
- Use MultiProvider for multiple models
- Keep models focused (single responsibility)

**DON'T ❌:**

- Don't use context.read inside build
- Don't forget notifyListeners
- Don't create Provider below MaterialApp (usually)
- Don't use context.watch in callbacks

> ⚠️ **TROUBLESHOOTING - Advanced Provider**:
>
> **Problem**: "Bad state: No ChangeNotifierProvider found"
>
> - **Cause**: Using Provider context above MaterialApp
> - **Fix**: Use Builder or separate widget
>
> **Problem**: "Too many rebuilds / Performance slow"
>
> - **Cause**: Using context.watch instead of Consumer
> - **Fix**: Use Consumer for specific widgets
> - **Or**: Use Selector for single fields
>
> **Problem**: "Selector not updating"
>
> - **Cause**: Selector returning same object reference
> - **Fix**: Return primitive (int, String) or override `==`

---

## 🎯 PART 7: Wrap Up & Review (5 menit)

### ✅ Yang Sudah Dipelajari

1. **Ephemeral vs App State** - Local vs shared state
2. **setState Limitations** - Prop drilling problem
3. **Provider Package** - Official state management
4. **ChangeNotifier Pattern** - Observable state
5. **Consumer / watch / read** - Different access methods
6. **Shopping Cart** - Real-world implementation

### 🏆 Achievement Unlocked

- ✅ Bisa explain setState limitations (prop drilling)
- ✅ Bisa create ChangeNotifier class dari scratch
- ✅ Bisa setup Provider di app level
- ✅ Bisa consume state dengan Consumer
- ✅ Bisa update state dengan context.read
- ✅ Working shopping cart app! 🛒

### 📝 Tugas Rumah - Shopping Cart Enhancement

**WAJIB (70 points)**:

1. ✓ Add to cart from product list
2. ✓ Show cart items dengan quantity
3. ✓ Update quantity (+/-)
4. ✓ Remove items from cart
5. ✓ Display total price correctly

**BONUS (+30 points)**:

1. **Search/Filter** (+10) - Search products by name
2. **Categories** (+10) - Filter products by category
3. **Checkout Page** (+10) - Order summary + form

**Deadline**: H+7 (Submit via GitHub)

---

## ❓ FAQ - Frequently Asked Questions

### Q1: Kapan pakai setState vs Provider?

**A**:

- **setState** → State LOCAL ke 1 widget (form input, toggle, simple counter)
- **Provider** → State SHARED antar >2 widgets (cart, user, theme)

**Rule**: Kalau >2 widgets perlu same data → Provider!

### Q2: Apa bedanya ChangeNotifier vs StreamController?

**A**:

- **ChangeNotifier** → For state management (simpler, recommended)
- **StreamController** → For async data streams (complex events)

Provider uses ChangeNotifier internally (easier API).

### Q3: Kenapa Provider lebih baik dari InheritedWidget?

**A**: Provider IS InheritedWidget + extra features:

- ✅ Lazy loading
- ✅ Dispose management
- ✅ Better API (Consumer, watch, read)
- ✅ MultiProvider support
- ✅ Official recommendation

### Q4: Bagaimana cara multiple providers?

**A**: Use `MultiProvider`!

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartModel()),
    ChangeNotifierProvider(create: (_) => UserModel()),
  ],
  child: MyApp(),
)
```

### Q5: Apa bedanya Consumer, context.watch, dan context.read?

**A**:

|                       | Consumer           | watch            | read   |
| --------------------- | ------------------ | ---------------- | ------ |
| **Rebuild**     | ✅ Specific widget | ✅ Entire widget | ❌ No  |
| **In build**    | ✅ Yes             | ✅ Yes           | ❌ No  |
| **In callback** | ❌ No              | ❌ No            | ✅ Yes |

**Use**: Consumer (targeted), watch (simple), read (callbacks).

### Q6: Bagaimana cara test code yang pakai Provider?

**A**: Inject mock Provider in tests:

```dart
testWidgets('Cart test', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => MockCartModel(), // Mock!
      child: MyApp(),
    ),
  );
});
```

### Q7: Bisa pakai Provider dengan StatelessWidget?

**A**: YES! Provider works dengan StatelessWidget:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    return Text('${cart.itemCount}');
  }
}
```

No need StatefulWidget untuk Provider!

### Q8: Apakah Provider cukup untuk app besar?

**A**:

For **most apps** → YES! Provider sufficient.

Consider alternatives when:

- Very complex state logic → **Bloc**
- Many async operations → **Riverpod**
- Enterprise scale → **Bloc** + **Clean Architecture**

**Recommendation**: Start Provider, upgrade kalau perlu!

---

## 👨‍🏫 FOR INSTRUCTORS ONLY

> 📌 Instruksi untuk Dosen/Instruktur

### Persiapan Sebelum Kelas (30 menit)

1. **Test All Code**

   - Run counter demo
   - Run shopping cart
   - Verify Provider package installed
   - Test on physical device
2. **Prepare Materials**

   - Prop drilling slides/diagram
   - Provider flow diagram
   - Shopping cart wireframe
3. **Setup Classroom**

   - Projector tested
   - Sample apps running
   - WiFi stable for pub get

### Timeline Management (STRICT 150 min)

**Cannot skip**:

- Part 0: 10 min (quiz bisa shortened)
- Part 1: 15 min (core concepts)
- Part 2: 20 min (show the problem!)
- Part 4: 25 min (ChangeNotifier basics)
- Part 5: 50 min (main project)

**Can adjust**:

- Part 3: 10 min → 7 min (skip history)
- Part 6: 15 min → 10 min (skip Selector)
- Part 7: 5 min → 3 min (quick review)

**If running late**: Skip Part 6 entirely, focus on working cart.

### Common Student Mistakes

1. **Forgot notifyListeners()** - MOST COMMON!

   - Symptom: State changes but UI doesn't update
   - Fix: Check every method calls notifyListeners()
2. **context.read in build method**

   - Error: "Don't use read inside build"
   - Fix: Use watch or Consumer
3. **Provider not in ancestor**

   - Error: "Could not find Provider"
   - Fix: Check ChangeNotifierProvider wraps widget
4. **Multiple Provider instances**

   - Problem: Each page has own cart
   - Fix: Provider in main.dart ONCE
5. **Disposed ChangeNotifier**

   - Error: after dispose
   - Fix: Provider handles dispose automatically

### Grading Praktikum (100 points)

| Kriteria               | Weight | Details                                                     |
| ---------------------- | ------ | ----------------------------------------------------------- |
| **CartModel**    | 25%    | ChangeNotifier, add/remove/update, getters, notifyListeners |
| **Product List** | 20%    | Display, add to cart, badge updates                         |
| **Cart Page**    | 25%    | Show items, quantity controls, remove, total                |
| **Navigation**   | 15%    | Badge, navigate to cart, data persists                      |
| **Code Quality** | 15%    | Clean, no warnings, proper naming                           |

**Bonus** (+20):

- Clear cart (+5)
- Search (+10)
- Checkout flow (+5)

### Discussion Prompts

- "Aplikasi favorit kalian yang punya shopping cart?"
- "Kenapa Instagram/Twitter perlu state management?"
- "Bedanya refresh feed vs update cart?"

### Differentiation

**Fast learners**:

- Implement search/filter
- Add product categories
- Persistent cart (SharedPreferences)
- Checkout with form

**Struggling students**:

- Provide skeleton code
- Focus on add/remove only (skip quantity)
- Pair programming
- Reference solution available

---

**🎉 Pertemuan 4 Complete!**

**Next**: Pertemuan 5 - Forms, Validasi & Debugging
