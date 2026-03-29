enum EntityMutationType {
  created,
  updated,
  deleted,
}

abstract class AppDomainEvent {
  const AppDomainEvent({
    required this.entityId,
    required this.mutation,
  });

  final String entityId;
  final EntityMutationType mutation;
}

class AuctionChangedEvent extends AppDomainEvent {
  const AuctionChangedEvent({
    required super.entityId,
    required super.mutation,
  });
}

class ItemChangedEvent extends AppDomainEvent {
  const ItemChangedEvent({
    required super.entityId,
    required super.mutation,
  });
}

class OrderChangedEvent extends AppDomainEvent {
  const OrderChangedEvent({
    required super.entityId,
    required super.mutation,
  });
}
