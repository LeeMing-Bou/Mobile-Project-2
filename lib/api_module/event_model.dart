// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

EventModel eventModelFromJson(String str) => EventModel.fromJson(json.decode(str));

String eventModelToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
    final List<Event> data;
    final EventModelLinks links;
    final Meta meta;

    EventModel({
        required this.data,
        required this.links,
        required this.meta,
    });

    factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        data: List<Event>.from(json["data"].map((x) => Event.fromJson(x))),
        links: EventModelLinks.fromJson(json["links"]),
        meta: Meta.fromJson(json["meta"]),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "links": links.toJson(),
        "meta": meta.toJson(),
    };
}

class Event {
    final Type type;
    final String id;
    final Attributes attributes;
    final List<dynamic> relationships;
    final DatumLinks links;

    Event({
        required this.type,
        required this.id,
        required this.attributes,
        required this.relationships,
        required this.links,
    });

    factory Event.fromJson(Map<String, dynamic> json) => Event(
        type: typeValues.map[json["type"]]!,
        id: json["id"],
        attributes: Attributes.fromJson(json["attributes"]),
        relationships: List<dynamic>.from(json["relationships"].map((x) => x)),
        links: DatumLinks.fromJson(json["links"]),
    );

    Map<String, dynamic> toJson() => {
        "type": typeValues.reverse[type],
        "id": id,
        "attributes": attributes.toJson(),
        "relationships": List<dynamic>.from(relationships.map((x) => x)),
        "links": links.toJson(),
    };
}

class Attributes {
    final String title;
    final String featureImage;
    final DateTime startDate;
    final DateTime? endDate;
    final int favoritesCount;
    final int participantsCount;
    final bool isFavorited;
    final bool? isParticipant;
    final bool isFeatured;

    Attributes({
        required this.title,
        required this.featureImage,
        required this.startDate,
        required this.endDate,
        required this.favoritesCount,
        required this.participantsCount,
        required this.isFavorited,
        required this.isParticipant,
        required this.isFeatured,
    });

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        title: json["title"],
        featureImage: json["feature_image"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        favoritesCount: json["favorites_count"],
        participantsCount: json["participants_count"],
        isFavorited: json["is_favorited"],
        isParticipant: json["is_participant"],
        isFeatured: json["is_featured"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "feature_image": featureImage,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "favorites_count": favoritesCount,
        "participants_count": participantsCount,
        "is_favorited": isFavorited,
        "is_participant": isParticipant,
        "is_featured": isFeatured,
    };
}

class DatumLinks {
    final String self;
    final String toggleFavorite;

    DatumLinks({
        required this.self,
        required this.toggleFavorite,
    });

    factory DatumLinks.fromJson(Map<String, dynamic> json) => DatumLinks(
        self: json["self"],
        toggleFavorite: json["toggleFavorite"],
    );

    Map<String, dynamic> toJson() => {
        "self": self,
        "toggleFavorite": toggleFavorite,
    };
}

enum Type {
    EVENTS
}

final typeValues = EnumValues({
    "events": Type.EVENTS
});

class EventModelLinks {
    final String first;
    final String last;
    final dynamic prev;
    final String next;

    EventModelLinks({
        required this.first,
        required this.last,
        required this.prev,
        required this.next,
    });

    factory EventModelLinks.fromJson(Map<String, dynamic> json) => EventModelLinks(
        first: json["first"],
        last: json["last"],
        prev: json["prev"],
        next: json["next"],
    );

    Map<String, dynamic> toJson() => {
        "first": first,
        "last": last,
        "prev": prev,
        "next": next,
    };
}

class Meta {
    final int currentPage;
    final int from;
    final int lastPage;
    final List<Link> links;
    final String path;
    final int perPage;
    final int to;
    final int total;

    Meta({
        required this.currentPage,
        required this.from,
        required this.lastPage,
        required this.links,
        required this.path,
        required this.perPage,
        required this.to,
        required this.total,
    });

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["current_page"],
        from: json["from"],
        lastPage: json["last_page"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        path: json["path"],
        perPage: json["per_page"],
        to: json["to"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "from": from,
        "last_page": lastPage,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "path": path,
        "per_page": perPage,
        "to": to,
        "total": total,
    };
}

class Link {
    final String url;
    final String label;
    final bool active;

    Link({
        required this.url,
        required this.label,
        required this.active,
    });

    factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
