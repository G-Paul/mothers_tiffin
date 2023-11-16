import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final Function changeCart;
  final num quantity;
  const ItemTile({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.changeCart,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(alignment: Alignment.bottomLeft, children: [
        Container(
          height: 200,
          width: 175,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  imageUrl,
                ),
                fit: BoxFit.cover,
              )),
        ),
        Container(
          height: 100,
          width: 175,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.05),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
            bottom: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹ $price",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  quantity == 0
                      ? InkWell(
                          onTap: () {
                            changeCart(
                                id: id,
                                price: price,
                                title: title,
                                imageUrl: imageUrl,
                                inc: 0);
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            InkWell(
                              onTap: () {
                                changeCart(
                                    id: id,
                                    price: price,
                                    title: title,
                                    imageUrl: imageUrl,
                                    inc: -1);
                              },
                              child: Container(
                                height: 30,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                            InkWell(
                                child: Container(
                              height: 30,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: Center(
                                child: Text(
                                  "$quantity",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            )),
                            InkWell(
                              onTap: () {
                                changeCart(
                                    id: id,
                                    price: price,
                                    title: title,
                                    imageUrl: imageUrl,
                                    inc: 1);
                              },
                              child: Container(
                                height: 30,
                                width: 25,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
