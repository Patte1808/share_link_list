import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final String tableShare = "share";
final String columnId = "_id";
final String columnTitle = "title";
final String columnIsFetched = "isFetched";
final String columnDescription = "description";
final String columnThumbnailUrl = "thumbnailUrl";
final String columnUserTitle = "userTitle";
final String columnShareUrl = "shareUrl";

final String tableHashtag = "hashtag";
final String columnHashtagId = "_hashtagId";
final String columnHashtagTitle = "hashtag_title";

final String tableHashtagShares = "hashtag_shares";
final String columnHashtagSharesId = "_hashtag_shares_id";
final String columnHashtagKey = "hashtag_key";
final String columnShareKey = "share_key";

class Hashtag {
  int id;
  String title;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnHashtagId: id,
      columnHashtagTitle: title,
    };
    if (id != null) {
      map[columnHashtagId] = id;
    }
    return map;
  }

  Hashtag(String hashtagTitle) {
    title = hashtagTitle;
  }

  Hashtag.fromMap(Map<String, dynamic> map) {
    id = map[columnHashtagId];
    title = map[columnHashtagTitle];
  }
}

class Share {
  int id;
  String title;
  String userTitle;
  bool isFetched;
  String description;
  String thumbnailUrl;
  String shareUrl;
  List<Hashtag> hashtags;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnIsFetched: isFetched == true ? 1 : 0,
      columnThumbnailUrl: thumbnailUrl,
      columnDescription: description,
      columnUserTitle: userTitle,
      columnShareUrl: shareUrl,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Share();

  Share.fromMap(Map<String, dynamic> valueMap) {
    id = valueMap[columnId];
    title = valueMap[columnTitle];
    isFetched = valueMap[columnIsFetched] == 1;
    description = valueMap[columnDescription];
    thumbnailUrl = valueMap[columnThumbnailUrl];
    userTitle = valueMap[columnUserTitle];
    shareUrl = valueMap[columnShareUrl];

    if (valueMap['hashtags'] != null) {
      List<String> hashtagList = valueMap['hashtags'].split(',').toList();

      hashtagList.forEach((hashtag) {
        if (hashtags == null) {
          hashtags = [];
        }
        print("Add $hashtag");
        hashtags.add(Hashtag(hashtag));

        print("Last ${hashtags.last.title}");
      });
    }
  }

  Share.fromMetaData(Map<String, dynamic> map) {
    if (map['image:secure_url'] != null) {
      thumbnailUrl = map['image:secure_url'];
    }

    if (map['title'] != null) {
      title = map['title'];
    }

    if (map['description'] != null) {
      description = map['description'];
    }

    if (map['url'] != null) {
      shareUrl = map['url'];
    }
  }
}

class ShareProvider {
  Database _db;

  static final ShareProvider _shareProvider = ShareProvider._internal();

  static ShareProvider get() {
    return _shareProvider;
  }

  ShareProvider._internal();

  Future init() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "share_db_4.db");

    print("init");

    _db = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table $tableShare (
          $columnId integer primary key autoincrement,
          $columnDescription text,
          $columnTitle text,
          $columnIsFetched integer not null,
          $columnThumbnailUrl text,
          $columnUserTitle text,
          $columnShareUrl text
        )
      ''');

      await db.execute('''
        create table $tableHashtagShares (
          $columnHashtagSharesId integer primary key autoincrement,
          $columnShareKey integer REFERENCES $tableShare ($columnId),
          $columnHashtagKey integer REFERENCES $tableHashtag ($columnHashtagId)
        )
      ''');

      await db.execute('''
        create table $tableHashtag (
          $columnHashtagId integer primary key autoincrement,
          $columnHashtagTitle text
        )
      ''');
    });
  }

  Future<Share> insert(Share share) async {
    if (_db == null) {
      await init();
    }

    print(share.toMap());
    share.id = await _db.insert(tableShare, share.toMap());
    print(share.toMap());

    if (share.hashtags.length > 0) {
      share.hashtags.forEach((hashtag) async {
        if (hashtag.id == null) {
          hashtag = await insertHashtag(hashtag);
        }

        await insertHashtagShare(hashtag, share);
      });
    }

    return share;
  }

  Future<List<Share>> getAll() async {
    if (_db == null) {
      await init();
    }

    var result = await _db.rawQuery('SELECT $tableShare.$columnId, $tableShare.$columnThumbnailUrl,'
        '$tableShare.$columnTitle, $tableShare.$columnDescription,'
        'GROUP_CONCAT($tableHashtag.$columnHashtagTitle) as hashtags FROM $tableShare LEFT JOIN $tableHashtagShares ON ($tableHashtagShares.$columnShareKey = $tableShare.$columnId) LEFT JOIN $tableHashtag ON ($tableHashtag.$columnHashtagId = $tableHashtagShares.$columnHashtagKey) GROUP BY $tableShare.$columnId');

    print(result);
    var hashtagShares = await _db.rawQuery('SELECT * FROM $tableHashtagShares');

    print(hashtagShares);

    var hashtags = await _db.rawQuery('SELECT * FROM $tableHashtag');

    print(hashtags);

    var shares = await _db.rawQuery('SELECT * FROM $tableShare');

    print(shares);
    return result.map((item) => Share.fromMap(item)).toList();
  }

  Future<Hashtag> getHashtag(String hashtag) async {
    if (_db == null) {
      await init();
    }

    var result = await _db.query(tableHashtag,
        where: "$columnHashtagTitle = ?", whereArgs: [hashtag]);

    if (result.length > 0) {
      return Hashtag.fromMap(result.first);
    }

    return null;
  }

  Future<Hashtag> insertHashtag(Hashtag hashtag) async {
    if (_db == null) {
      await init();
    }

    if (hashtag.title == null || hashtag.title.isEmpty) {
      return hashtag;
    }

    hashtag.id = await _db.insert(tableHashtag, hashtag.toMap());

    return hashtag;
  }

  Future insertHashtagShare(Hashtag hashtag, Share share) async {
    if (_db == null) {
      await init();
    }

    await _db.insert(tableHashtagShares, {columnHashtagKey: hashtag.id, columnShareKey: share.id});
  }
}
