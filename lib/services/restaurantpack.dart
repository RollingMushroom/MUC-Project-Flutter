import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../JsonModels/admin.dart';
import '../JsonModels/users.dart';
import '../JsonModels/booking.dart';

class DatabaseHelper {
  final databaseName = "restaurant.db";

  // Create user table
  String users =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, email TEXT UNIQUE, phone INTEGER, username TEXT UNIQUE, password TEXT)";

  // Create menubook table with foreign key reference to users
  String menubook =
      "CREATE TABLE menubook (bookId INTEGER PRIMARY KEY AUTOINCREMENT, usrId INTEGER, bookdate DATE, booktime TIME, eventdate DATE, eventtime TIME, numguests INTEGER, packageprice DOUBLE, menupackage TEXT, function TEXT, FOREIGN KEY(usrId) REFERENCES users(usrId))";

  // Create admin table
  String administrator =
      "CREATE TABLE administrator (adminId INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)";

  // Method to check if a username is an admin
  Future<bool> isAdmin(String username, String password) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM administrator WHERE username = ? AND password = ?",
        [username, password]);
    return result.isNotEmpty;
  }

  // Initialize the database
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(menubook);
      await db.execute(administrator);
    });
  }

  // Login Method for User
  Future<Users?> login(Users user) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE username = ? AND password = ?",
        [user.username, user.password]);

    if (result.isNotEmpty) {
      return Users.fromMap(result.first);
    }
    return null;
  }

  // Login Method for Admin
  Future<bool> adminLogin(Admin admin) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM administrator WHERE username = ? AND password = ?",
        [admin.username, admin.password]);
    return result.isNotEmpty;
  }

  // Sign up
  Future<int> signup(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  // Update User
  Future<int> updateUser(Users user) async {
    final Database db = await initDB();
    return await db.update(
      'users',
      user.toMap(),
      where: 'usrId = ?',
      whereArgs: [user.usrId],
    );
  }

  // Insert booking details
  Future<int> insertBooking(Map<String, dynamic> bookingDetails) async {
    final Database db = await initDB();
    return db.insert('menubook', bookingDetails);
  }

  // Fetch bookings for a specific user
  Future<List<Map<String, dynamic>>> getUserBookings(int usrId) async {
    final Database db = await initDB();
    return db.query('menubook', where: 'usrId = ?', whereArgs: [usrId]);
  }

  Future<Users> getUser(String username) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result =
        await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isNotEmpty) {
      return Users.fromMap(result.first);
    } else {
      throw Exception("User not found");
    }
  }

  Future<List<Map<String, dynamic>>> getBookingHistory(int usrId) async {
    final Database db = await initDB();
    return await db.query('menubook', where: 'usrId = ?', whereArgs: [usrId]);
  }

  Future<List<Map<String, dynamic>>> getBookingsForAdmin(
      int usrId, int bookId) async {
    final Database db = await initDB();
    return await db.query('menubook', where: 'usrId = ?', whereArgs: [usrId]);
  }

  // Update booking details
  Future<int> updateBooking(
      int bookId, Map<String, dynamic> updatedDetails) async {
    final Database db = await initDB();
    return await db.update(
      'menubook',
      updatedDetails,
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  // Delete booking
  Future<int> deleteBooking(int bookId) async {
    final Database db = await initDB();
    return await db.delete(
      'menubook',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  // Fetch all users
  Future<List<Users>> getAllUsers() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> results = await db.query('users');
    List<Users> usersList =
        results.map((userMap) => Users.fromMap(userMap)).toList();
    return usersList;
  }

  // Fetch all bookings
  Future<List<Booking>> getAllBookings() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> results = await db.query('menubook');
    List<Booking> bookingList =
        results.map((bookingMap) => Booking.fromMap(bookingMap)).toList();
    return bookingList;
  }

  // Delete user
  Future<int> deleteUser(int usrId) async {
    final Database db = await initDB();
    return await db.delete('users', where: 'usrId = ?', whereArgs: [usrId]);
  }

  // Fetch all booking histories
  Future<List<Map<String, dynamic>>> getAllBookingHistories() async {
    final Database db = await initDB();
    return await db.query('menubook');
  }
}
